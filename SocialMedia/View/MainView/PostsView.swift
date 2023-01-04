//
//  PostsView.swift
//  SocialMedia
//
//  Created by Seungchul Ha on 2023/01/04.
//

import SwiftUI

struct PostsView: View {
    
    @State private var recentsPosts: [Post] = []
    @State private var createNewPost: Bool = false
    
    var body: some View {
        NavigationStack {
            ReusablePostsView(posts: $recentsPosts)
                .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black, in: Circle())
                    }
                    .padding(15)
                }
                .navigationTitle("Post's")
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost { post in
              	/// - Adding Created post at the Top of the Recent Posts
                recentsPosts.insert(post, at: 0)
            }
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}

/// Part 4: In this part, we will see how to create a layout for viewing the published posts with post interactions (like or dislike)
/// and also allowing the post author to delete the post.
///
/// part 5: I will explain about adding pagination to the post's section and implementing the search user feature
