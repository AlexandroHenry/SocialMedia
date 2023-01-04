//
//  PostsView.swift
//  SocialMedia
//
//  Created by Seungchul Ha on 2023/01/04.
//

import SwiftUI

struct PostsView: View {
    
    @State private var createNewPost: Bool = false
    
    var body: some View {
        Text("Hello, World!")
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
            .fullScreenCover(isPresented: $createNewPost) {
                CreateNewPost { post in
                    
                }
            }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
