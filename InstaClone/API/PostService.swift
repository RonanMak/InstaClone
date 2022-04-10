//
//  PostService.swift
//  InstaClone
//
//  Created by Ronan Mak on 13/3/2022.
//

import UIKit
import Firebase

struct PostService {
    
    static func uploadPost(caption: String, image: UIImage, user: User,
                           completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption": caption,
                        "timestamp": Timestamp(date: Date()),
                        "likes": 0,
                        "imageUrl": imageUrl,
                        "ownerUid": uid,
                        "ownerImageUrl": user.profileImageUrl,
                        "ownerUsername": user.username] as [String : Any]
                        
            COLLECTION_POSTS.addDocument(data: data, completion: completion)
        }
    }
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            completion(posts)
        }
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(posts)
        }
    }
    
    static func fetchPost(withPostId postId: String, completion: @escaping(Post) -> Void) {
        COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let post = Post(postId: snapshot.documentID, dictionary: data)
            completion(post)
        }
    }
    
    static func fetchPosts(forHashtag hashtag: String, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        print("666", posts)
        COLLECTION_HASHTAGS.document(hashtag).collection("posts").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            print("888", posts)
            documents.forEach({ fetchPost(withPostId: $0.documentID) { post in
                posts.append(post)
                completion(posts)
            } })
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])
        
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData([:]) { _ in
            
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).setData([:], completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])
        
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { _ in
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).getDocument { (snapshot, _) in
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    
    static func fetchFeedPosts(completion: @escaping([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var posts = [Post]()
        print("123", posts)
        COLLECTION_USERS.document(uid).collection("user-feed").getDocuments { snapshot, error in
            print("999", snapshot?.documents)
            snapshot?.documents.forEach({ document in
                fetchPost(withPostId: document.documentID) { post in
                    posts.append(post)
                    print("777", posts)
//                    posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    completion(posts)
                }
            })
        }
    }
    
    static func deletePost(_ postId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS.document(postId).collection("post-likes").getDocuments { snapshot, _ in
            guard let uids = snapshot?.documents.map({ $0.documentID }) else { return }
            uids.forEach({ COLLECTION_USERS.document($0).collection("user-likes").document(postId).delete() })
        }
        
        COLLECTION_POSTS.document(postId).delete { _ in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
                guard let uids = snapshot?.documents.map({ $0.documentID }) else { return }
                
                uids.forEach({ COLLECTION_USERS.document($0).collection("user-feed").document(postId).delete() })
                
                let notificationQuery = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications")
                notificationQuery.whereField("postId", isEqualTo: postId).getDocuments { snapshot, _ in
                    guard let documents = snapshot?.documents else { return }
                    documents.forEach({ $0.reference.delete(completion: completion) })
                }
            }
        }
    }
    
    static func updateUserFeedAfterFollowing(user: User, didFollow: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)
        
        query.getDocuments { (snapshot, errot) in
            guard let documents = snapshot?.documents else { return }
            
            let documentIDs = documents.map({ $0.documentID })
            
            documentIDs.forEach { id in
                
                if didFollow {
                    COLLECTION_USERS.document(uid).collection("user-feed").document(id).setData([:])
                } else {
                    COLLECTION_USERS.document(uid).collection("user-feed").document(id).delete()
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
