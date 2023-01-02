//
//  ResuableProfileContent.swift
//  SocialMedia
//
//  Created by Seungchul Ha on 2023/01/03.
//

import SwiftUI
import SDWebImageSwiftUI

/// Why?
/// Since Social Media App contains a search user feature,
/// making this component reusable will avoid more redundant codes
/// and also make it easy to display user details simply with a User Model Object

struct ReusableProfileContent: View {
    
    var user: User
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                HStack(spacing: 12) {
                    WebImage(url: user.userProfileURL).placeholder {
                        // MARK: Placeholder Image
                        Image("NullProfile")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        // MARK: Displaying Bio Link, If Given While Signing Up Profile Page
                        if let bioLink = URL(string: user.userBioLink) {
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
            }
            .padding(15)
        }
    }
}
