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
    
    @Binding var posts: [Post]
    
    /// - View Properties
    @State var isFetching: Bool = false
    
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
            isFetching = true
            posts = []
            await fetchPosts()
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
            
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    /// - Fetching Posts
    func fetchPosts() async {
        do {
            var query: Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "publishedDate", descending: true)
                .limit(to: 20)
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts = fetchedPosts
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
