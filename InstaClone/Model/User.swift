//
//  User.swift
//  InstaClone
//
//  Created by Ronan Mak on 23/2/2022.
//

import Foundation
import Firebase

// MARK: - Model for a user
// mirror all of the properties that the database have.
// including 1. email, 2. email, 3. fullname, 4. userID, 5. username
struct User {
    let email: String
    let fullname: String
    let username: String
    let userID: String
    let profileImageUrl: String
    
    var isFollowed = false
    
    var stats: UserStats!
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == userID}
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.userID = dictionary["userID"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        self.stats = UserStats(followers: 0, following: 0)
    }
}

struct UserStats {
    let followers: Int
    let following: Int
    // let posts: Int
}
