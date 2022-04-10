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
        
        docRef.setData(data)
    }
    
    // NEW
    static func deleteNotification(toUid uid: String, type: NotificationType, postId: String? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications")
            .whereField("uid", isEqualTo: currentUid).getDocuments { snapshot, _ in
                snapshot?.documents.forEach({ document in
                    let notification = Notification(dictionary: document.data())
                    guard notification.type == type else { return }
                    
                    if postId != nil {
                        guard postId == notification.postID else { return }
                    }
                    
                    document.reference.delete()
                })
            }
    }
    
    static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_NOTIFICATIONS.document(userID).collection("user-notifications").order(by: "timestamp", descending: true)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let notifications = documents.map({ Notification(dictionary: $0.data()) })
            completion(notifications)
        }
    }
}
