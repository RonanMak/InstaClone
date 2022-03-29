//
//  NotificationViewModel.swift
//  InstaClone
//
//  Created by Ronan Mak on 26/3/2022.
//

import UIKit
import SwiftUI

struct NotificationViewModel {
    var notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var postImageUrl: URL? { return URL(string: notification.postImageUrl ?? "") }
    
    var userProfileImageUrl: URL? { return URL(string: notification.userProfileImageUrl) }
    
    var notificationMessage: NSAttributedString {
        let username = notification.username
        let messagge = notification.type.notificationMessage
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: messagge, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: " 2m", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.lightGray]))
        
        return attributedText
    }
    
    var shouldHidePostImage: Bool { return self.notification.type == .follow }
    
    var followButtonText: String { return notification.userIsFollowed ? "Following" : "Follow" }
    
    var followButtonBackgroundColor: UIColor { return notification.userIsFollowed ? .white : .systemBlue }
    
    var followButtonTextColor: UIColor { return notification.userIsFollowed ? .black : .white }
        
}
