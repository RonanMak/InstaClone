//
//  UserProfileService.swift
//  InstaClone
//
//  Created by Ronan Mak on 23/2/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

typealias FirestoreCompletion = (Error?) -> Void

struct UserProfileService {

    // call this func once it's done doing its thing, and execute the completion handler, then give a user back.
    static func fetchUser(withUserID userID: String, completion: @escaping(User) -> Void) {
//        guard let userID = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(userID).getDocument {
            snapchot, error in
           
            guard let dictionary = snapchot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    //NEW
    static func fetchUser(withUsername username: String, completion: @escaping(User?) -> Void) {
        COLLECTION_USERS.whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            guard let document = snapshot?.documents.first else {
                completion(nil)
                return
            }
            let user = User(dictionary: document.data())
            completion(user)
        }
    }
    
    //NEW
    private static func fetchUsers(fromCollection collection: CollectionReference, completion: @escaping([User]) -> Void) {
        var users = [User]()

        collection.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            documents.forEach({ fetchUser(withUserID: $0.documentID) { user in
                users.append(user)
                completion(users)
            } })
        }
    }
    
    //NEW
    static func fetchUsers(forConfig config: UserFilterConfig, completion: @escaping([User]) -> Void) {
        switch config {
        case .followers(let uid):
            let ref = COLLECTION_FOLLOWERS.document(uid).collection("user-followers")
            fetchUsers(fromCollection: ref, completion: completion)
            
        case .following(let uid):
            let ref = COLLECTION_FOLLOWING.document(uid).collection("user-following")
            fetchUsers(fromCollection: ref, completion: completion)
            
        case .likes(let postId):
            let ref = COLLECTION_POSTS.document(postId).collection("post-likes")
            fetchUsers(fromCollection: ref, completion: completion)
            
        case .all, .messages:
            COLLECTION_USERS.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                
                let users = snapshot.documents.map({ User(dictionary: $0.data()) })
                completion(users)
            }
        }
    }
    
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            let users = snapshot.documents.map({ User(dictionary: $0.data()) })
            completion(users)
        }
    }
    
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
                
                COLLECTION_POSTS.whereField("ownerUserID", isEqualTo: userID).getDocuments { (snapshot, _) in
                    
                    guard let postNumber = snapshot?.documents.count else { return }
                    
                    completion(UserStats(followers: followersNumber, following: followingNumber, posts: postNumber))
                }
                

            }
        }
    }
    // NEW
    static func updateProfileImage(forUser user: User, image: UIImage, completion: @escaping(String?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
                
        ImageUploader.uploadImage(image: image) { profileImageUrl in
            let data = ["profileImageUrl": profileImageUrl]
            
            COLLECTION_USERS.document(uid).updateData(data) { error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.userID).getDocuments { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    let data = ["ownerImageUrl": profileImageUrl]
                    documents.forEach({ COLLECTION_POSTS.document($0.documentID).updateData(data) })
                }
                
                // need to update profile image url in comments and messages
                
                completion(profileImageUrl, nil)
            }
        }
    }
    
    static func saveUserData(user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = ["email": user.email,
                                   "fullname": user.fullname,
                                   "profileImageUrl": user.profileImageUrl,
                                   "uid": uid,
                                   "username": user.username]
        
        COLLECTION_USERS.document(uid).setData(data, completion: completion)
    }
    
    static func setUserFCMToken() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let fcmToken = Messaging.messaging().fcmToken else { return }

        COLLECTION_USERS.document(uid).updateData(["fcmToken": fcmToken])
    }
}
