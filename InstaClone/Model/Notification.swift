//
//  Notification.swift
//  InstaClone
//
//  Created by Ronan Mak on 25/3/2022.
//

import UIKit
import Firebase

// we use an enumeration to distinguish some sort of custom type, it's almost always integers.
enum NotificationType: Int {
    case like
    case follow
    case comment
    
    var notificationMessage: String {
        switch self {
        case .like:
            return " liked your post"
        case .follow:
            return " started following you"
        case .comment:
            return " commented on your post"
        }
    }
}

struct Notification {
    let userID: String
    var postImageUrl: String?
    var postID: String?
    let timestamp: Timestamp
    let type: NotificationType
    let notificationID: String
    let userProfileImageUrl: String
    let username: String
    var userIsFollowed = false
    
    init(dictionary: [String: Any]) {
        self.userID = dictionary["userID"] as? String ?? ""
        self.postImageUrl = dictionary["postImageUrl"] as? String ?? ""
        self.postID = dictionary["postID"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .like
        self.notificationID = dictionary["notificationID"] as? String ?? ""
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
    }
}
