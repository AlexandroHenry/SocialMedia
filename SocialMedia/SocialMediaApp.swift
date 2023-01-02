//
//  SocialMediaApp.swift
//  SocialMedia
//
//  Created by Seungchul Ha on 2023/01/02.
//

import SwiftUI
import Firebase

@main
struct SocialMediaApp: App {
    
    init() {
        FirebaseApp.configure() // Initializing Firebase
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
