//
//  NotificationService.swift
//  InstaClone
//
//  Created by Ronan Mak on 25/3/2022.
//

import UIKit
import Firebase

struct NotificationService {
    
    static func uploadNotification(toUserID userID: String,
                                   fromUser: User,
                                   type: NotificationType,
                                   post: Post? = nil) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        guard userID != currentUserID else { return }
        
        let docRef = COLLECTION_NOTIFICATIONS.document(userID).collection("user-notifications").document()
        
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "userID": fromUser.userID,
                                   "type": type.rawValue,
                                   "notificationID": docRef.documentID,
                                   "userProfileImageUrl": fromUser.profileImageUrl,
                                   "username": fromUser.username]
        
        if let post = post {
            data["postID"] = post.postID
            data["postImageUrl"] = post.imageUrl
        }
        
        print("\(data) jndsiojfiodsjifos")
        
        docRef.setData(data)
    }
    
    static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(userID).collection("user-notifications").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let notifications = documents.map({ Notification(dictionary: $0.data()) })
            completion(notifications)
        }
    }
}
