//
//  Comment.swift
//  InstaClone
//
//  Created by Ronan Mak on 20/3/2022.
//

import UIKit
import Firebase

struct Comment {
    let userID: String
    let username: String
    let profileImageUrl: String
    let commentText: String
    let timestamp: Timestamp
    //NEW
    let postOwnerUid: String
    
    init(dictionary: [String: Any]) {
        self.userID = dictionary["userID"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.commentText = dictionary["comment"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.postOwnerUid = dictionary["postOwnerUid"] as? String ?? ""
    }
}
