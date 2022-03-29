//
//  PostService.swift
//  InstaClone
//
//  Created by Ronan Mak on 13/3/2022.
//

import UIKit
import Firebase

struct PostService {
    
    static func uploadPost(caption: String, image: UIImage, user: User, completion: @escaping(FirestoreCompletion)) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = [
                "caption": caption,
                "timestamp": Timestamp(date: Date()),
                "likes": 0,
                "imageUrl": imageUrl,
                "ownerUserID": userID,
                "ownerImageUrl": user.profileImageUrl,
                "ownerUsername": user.username] as [String : Any]
            
            let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
            
            self.updateUserFeedAfterPost(postID: docRef.documentID)
        }
    }
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { (snapshot, errpr) in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map({ Post(postID: $0.documentID, dictionary: $0.data()) })
            completion(posts)
        }
    }
    
    static func fetchPosts(forUser userID: String, completion: @escaping([Post]) -> Void) {
        let query = COLLECTION_POSTS.whereField("ownerUserID", isEqualTo: userID)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            var posts = documents.map({ Post(postID: $0.documentID, dictionary: $0.data()) })
            
            posts.sort { (post1, post2) -> Bool in
                return post1.timestamp.seconds > post2.timestamp.seconds
            }
            
            completion(posts)
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS.document(post.postID).updateData(["likes" : post.likes + 1])
        
        COLLECTION_POSTS.document(post.postID).collection("post-likes").document(userID).setData([:]) { _ in
            
            COLLECTION_USERS.document(userID).collection("user-likes").document(post.postID).setData([:], completion: completion)
        }
    }
    
    static func fetchPost(withPostID postID: String, completion: @escaping(Post) -> Void) {
        COLLECTION_POSTS.document(postID).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let post = Post(postID: snapshot.documentID, dictionary: data)
            completion(post)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        
        COLLECTION_POSTS.document(post.postID).updateData(["likes" : post.likes - 1])
        
        COLLECTION_POSTS.document(post.postID).collection("post-likes").document(userID).delete { _ in
            COLLECTION_USERS.document(userID).collection("user-likes").document(post.postID).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_USERS.document(userID).collection("user-likes").document(post.postID).getDocument { (snapshot, _) in
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    
    static func fetchFeedPosts(completion: @escaping([Post]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        var posts = [Post]()
        
        COLLECTION_USERS.document(userID).collection("user-feed").getDocuments { snapshot, error in
            snapshot?.documents.forEach({ document in
                fetchPost(withPostID: document.documentID) { post in
                    posts.append(post)
                    completion(posts)
                }
            })
        }
    }
    
    static func updateUserFeedAfterFollowing(user: User, didFollow: Bool) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_POSTS.whereField("ownerUserID", isEqualTo: user.userID)
        
        query.getDocuments { (snapshot, errot) in
            guard let documents = snapshot?.documents else { return }
            
            let documentIDs = documents.map({ $0.documentID })
            
            documentIDs.forEach { id in
                
                if didFollow {
                    COLLECTION_USERS.document(userID).collection("user-feed").document(id).setData([:])
                } else {
                    COLLECTION_USERS.document(userID).collection("user-feed").document(id).delete()
                }
            }
        }
    }
    
    private static func updateUserFeedAfterPost(postID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWERS.document(userID).collection("user-followers").getDocuments { snapshot, _ in
            
            guard let documents = snapshot?.documents else { return }
            
            documents.forEach { document in
                COLLECTION_USERS.document(document.documentID).collection("user-feed").document(postID).setData([:])
            }
            
            COLLECTION_USERS.document(userID).collection("user-feed").document(postID).setData([:])
        }
    }
}
