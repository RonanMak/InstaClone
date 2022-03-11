//
//  UserProfileService.swift
//  InstaClone
//
//  Created by Ronan Mak on 23/2/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

typealias FirestoreCompletion = (Error?) -> Void

struct UserProfileService {

    // call this func once it's done doing its thing, and execute the completion handler, then give a user back.
    static func fetchUser(completion: @escaping(User) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(userID).getDocument {
            snapchot, error in
           
            guard let dictionary = snapchot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
//            guard let email = dictionary["email"] as? String else { return }
//
//            let user = User(email: <#T##String#>, fullname: <#T##String#>, username: <#T##String#>, userID: <#T##String#>, profileImageUrl: <#T##String#>)
            
        }
    }
    
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            let users = snapshot.documents.map({ User(dictionary: $0.data()) })
            completion(users)
        }
    }
    
//    static func fetchUser() {
//
//        var users = [User]()
//
//        COLLECTION_USERS.getDocuments { (snapshot, error) in
//
//            guard let snapshot = snapshot else { return }
//
//            snapshot.documents.forEach { document in print("\(document.data())")
//                let user = User(dictionary: document.data())
//                users.append(user)
//
//            }
//        }
//    }
    
    static func followUser(userID: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUserID).collection("user-following")
            .document(userID).setData([:]) { error in COLLECTION_FOLLOWERS.document(userID).collection("user-followers")
            .document(currentUserID).setData([:], completion: completion)
        }
    }
    
    static func unfollowUser(userID: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUserID).collection("user-following").document(userID).delete() {
            error in COLLECTION_FOLLOWERS.document(userID).collection("user-followers").document(currentUserID).delete(completion: completion)
        }        
    }
    
    static func checkIfUserIsFollowed(userID: String, completion: @escaping(Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUserID).collection("user-following").document(userID).getDocument {
            (snapshot, error) in
            
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
    static func fetchUserStats(userID: String, completion: @escaping(UserStats) -> Void) {
        COLLECTION_FOLLOWERS.document(userID).collection("user-followers").getDocuments { (snapshot, _) in
            
            guard let followersNumber = snapshot?.documents.count else { return }
            
            COLLECTION_FOLLOWING.document(userID).collection("user-following").getDocuments { (snapshot, _) in
                
                guard let followingNumber = snapshot?.documents.count else { return }
                
                completion(UserStats(followers: followersNumber, following: followingNumber))
            }
        }
    }
}
