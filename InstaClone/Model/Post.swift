//
//  Post.swift
//  InstaClone
//
//  Created by Ronan Mak on 15/3/2022.
//

import UIKit
import Firebase

struct Post {
    var caption: String
    var likes: Int
    let imageUrl: String
    let timestamp: Timestamp
    let ownerUserID: String
    let postID: String
    let ownerImageUrl: String
    let ownerUsername: String
    var didLike = false
    //NEW
    let hashtags: [String]
    
    init(postID: String, dictionary: [String: Any]) {
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.ownerUserID = dictionary["ownerUserID"] as? String ?? ""
        self.postID = postID
        self.ownerImageUrl = dictionary["ownerImageUrl"] as? String ?? ""
        self.ownerUsername = dictionary["ownerUsername"] as? String ?? ""
        //NEW
        self.hashtags = dictionary["hashtags"] as? [String] ?? [String]()
    } 
}
