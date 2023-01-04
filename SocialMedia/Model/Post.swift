//
//  Post.swift
//  SocialMedia
//
//  Created by Seungchul Ha on 2023/01/03.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift

// MARK: Post Model
struct Post: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
    // MARK: Basic User Info
    var userName: String
    var userUID: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case text // Post Content
        case imageURL // Post Image URL
        case imageReferenceID // Image Refernce ID (Used for Deletion)
        case publishedDate
        case likedIDs // People's user IDs who liked or dislied
        case dislikedIDs
        case userName // Post Author's basic info ( for Post View )
        case userUID
        case userProfileURL
    }
}
