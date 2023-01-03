//
//  CreateNewPost.swift
//  SocialMedia
//
//  Created by Seungchul Ha on 2023/01/03.
//

import SwiftUI

struct CreateNewPost: View {
    
    /// - Callbacks
    var onPost: (Post) -> ()
    
    /// - Post Properties
    @State private var postText: String = ""
    @State private var postImageData: Data?
    
    /// - Stored User Data From UserDefaults (AppStorage)
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    /// - View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(.black)
                }
                .hAlign(.leading)
                
                Button(action: {}) {
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(.black, in: Capsule())
                }
                .disableWithOpacity(postText == "")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    TextField("What's happenning?", text: $postText, axis: .vertical)
                    
                    if let postImageData, let image = UIImage(data: postImageData) {
                        GeometryReader {
                            let size = $0.size
                            
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }
            }
        }
        .vAlign(.top)
    }
}

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPost { _ in

        }
    }
}

// MARK: Part 3
/// In this part, we will see how to create a new post

// MARK: Part 4
/// will explain how to display those created posts with post interactions (likes and dislikes).

// MARK: Part 5
/// explain the process of the Search User Feature
