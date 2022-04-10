//
//  MessagingService.swift
//  InstaClone
//
//  Created by Ronan Mak on 9/4/2022.
//

import UIKit
import Firebase

struct MessagingService {
    
    
    static func fetchRecentMessages(completion: @escaping([Message]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(uid).collection("recent-messages").order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            guard let documentChanges = snapshot?.documentChanges else { return }
            let messages = documentChanges.map({ Message(dictionary: $0.document.data()) })
            completion(messages)
        }
    }
        
    static func fetchMessages(forUser user: User, completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var messages = [Message]()
        let query = COLLECTION_MESSAGES.document(currentUid).collection(user.userID).order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            guard let documentChanges = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            messages.append(contentsOf: documentChanges.map({ Message(dictionary: $0.document.data()) }))
            completion(messages)
        }
    }
    
    static func uploadMessage(_ message: String, to user: User, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["text": message,
                    "fromId": currentUid,
                    "toId": user.userID,
                    "timestamp": Timestamp(date: Date()),
                    "username": user.username,
                    "profileImageUrl": user.profileImageUrl] as [String : Any]
        
        COLLECTION_MESSAGES.document(currentUid).collection(user.userID).addDocument(data: data) { _ in
            COLLECTION_MESSAGES.document(user.userID).collection(currentUid).addDocument(data: data, completion: completion)
        COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.userID).setData(data)
            
        COLLECTION_MESSAGES.document(user.userID).collection("recent-messages").document(currentUid).setData(data)
        }
    }
    
    static func deleteMessages(withUser user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_MESSAGES.document(uid).collection(user.userID).getDocuments { snapshot, error in
            
            snapshot?.documents.forEach({ document in
                let id = document.documentID
                
                COLLECTION_MESSAGES.document(uid).collection(user.userID).document(id).delete()
            })
        }
        
        let ref = COLLECTION_MESSAGES.document(uid).collection("recent-messages").document(user.userID)
        ref.delete(completion: completion)
    }
}