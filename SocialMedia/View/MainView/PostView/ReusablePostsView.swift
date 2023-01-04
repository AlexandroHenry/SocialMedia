//
//  ResuablePostsView.swift
//  SocialMedia
//
//  Created by Seungchul Ha on 2023/01/04.
//

import SwiftUI
import FirebaseFirestore

/// Why Resuable?
/// we need to display the current user's posts on the profile screen,
/// and we also need to display that user's posts when searching for another user.
/// By making it a resuable component, we can easily remove lots of redundant codes.

struct ReusablePostsView: View {
    
    var basedOnUID: Bool = false
    var uid: String = ""
    
    @Binding var posts: [Post]
    
    /// - View Properties
    @State private var isFetching: Bool = false
    
    /// - Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            /// Why LazyVStack?
            /// By using LazyVStack, it removes the contents when it's moved out of the screen,
            /// allowing us to use onAppear() and onDisappear() to get notified
            /// when it's actually entering/ leaving the screen.
            LazyVStack {
                if isFetching {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if posts.isEmpty {
                        /// No Posts Found on Firestore
                        Text("No Posts Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                        
                    } else {
                        /// - Displaying Posts
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            
            /// - Scroll to Refresh
            /// Disabling Refresh for UId based Posts
            guard !basedOnUID else { return }
            isFetching = true
            posts = []
            
            /// - Resetting Pagination Doc
            ///  We must set paginationDoc to nil when the user refreshes the posts
            ///  since the user's refresh will begin with the most recently written posts
            ///  and, if the pagination doc hasn't been updated, will get the most recent documents.
            paginationDoc = nil
            await fetchPosts()
            
            
            /// 2023-01-05 00:07:36.330288+0900 SocialMedia[65698:1107686] 9.6.0 - [FirebaseFirestore][I-FST000001] Listen for query at Posts failed: The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/socialmediaapp-e6195/firestore/indexes?create_composite=ClJwcm9qZWN0cy9zb2NpYWxtZWRpYWFwcC1lNjE5NS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvUG9zdHMvaW5kZXhlcy9fEAEaCwoHdXNlclVJRBABGhEKDXB1Ymxpc2hlZERhdGUQAhoMCghfX25hbWVfXxAC
            ///
            /// Since we created a new query for the UID-based posts and it contains compund queries,
            /// Firebase will require us to generate indexes when we run compound queries.
            /// Compound queries can be easily created by pasting the provided link from the console into a browser
            /// and selecting the index option.
            /// Simply Enter to address above (in console) and create Index
        }
        .task {
            /// - Fetching For One Time
            guard posts.isEmpty else { return }
            await fetchPosts()
        }
    }
    
    /// Displaying Fetched Posts
    @ViewBuilder
    func Posts() -> some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                /// Updating Post in the Array
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }) {
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                /// Removing Post From the Array
                withAnimation(.easeInOut(duration: 0.25)) {
                    posts.removeAll { post.id == $0.id } // It is recommended by comparing id
                }
            }
            .onAppear {
                /// - When Last Post Appears, Fetching New Post ( If There )
                ///  Why check pagination document isn't null?
                ///  Consider that there are 40 posts total, and that the initial fetch fetched 20 posts,
                ///  with the pagination document being the 20th post, and that when the last post appears,
                ///  it fetches the next set of 20 posts, with the pagination document being the 40th post.
                ///  When it tries to fetch another set of 20, it will be empty because there are no more posts available,
                ///  so paginationDoc will be nil and it will no longer try to fetch the posts.
                
                if post.id == posts.last?.id && paginationDoc != nil {
                    Task { await fetchPosts() }
                }
            }
            
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    /// - Fetching Posts
    ///
    /// Updating the fetchPosts() function to check whether to fetch the recent posts or posts for a given user UID.
    func fetchPosts() async {
        do {
            var query: Query!
            
            /// - Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            
            /// - New Query For UID Based Document Fetch
            /// Simply Filter the Posts which is not belongs to this UID
            if basedOnUID {
                query = query
                    .whereField("userUID", isEqualTo: uid)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                
                /// Saving the last fetched document so that it can be used for pagination in the Firebase Firestore
                paginationDoc = docs.documents.last
                
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
