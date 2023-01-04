//
//  SearchUserView.swift
//  SocialMedia
//
//  Created by Seungchul Ha on 2023/01/04.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    
    /// - View Properties
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        /// Since there is already NavigationStack in the PostView,  NavigationStack does not need from the SearchUserView
        List {
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    /// This is why we created the Reusable Profile View, so that if you pass it a user object,
                    /// it will simply display all of the user's detains, avoiding redundancy codes
                    ReusableProfileContent(user: user)
                } label: {
                    Text(user.username)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $searchText)
        .onSubmit(of: .search, {
            /// - Fetch User From Firebase
            Task { await searchUsers() }
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUsers = []
            }
        })
    }
    
    func searchUsers() async {
        do {
//            let queryLowerCased = searchText.lowercased()
//            let queryUpperCased = searchText.uppercased()
            
            /// refer : https://stackoverflow.com/questions/46568142/google-firestore-query-on-substring-of-a-property-value-text-search
            /// above link, could check out how it actually works
            /// it is kinda limited(Constraints), so the best way is to store the user name in all lowercase and search with lowercase instead.
            /// Because there is no way to search for "String Contains" in the Firebase Firestore,
            /// we must use greater or less than equivalence to find strings in the document.
            ///
            /// https://firebase.google.com/docs/firestore/solutions/search
            /// If need more advanced search functions, check out the SDKs prescribed by Firebase.
            ///
            /// Since I've stored the username in the way the user typed it,
            /// I'm passing the search text directly instead of making it lower case.
            
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
            
            /// - UI Must be Updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
