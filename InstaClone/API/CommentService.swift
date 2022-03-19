//
//  CommentService.swift
//  InstaClone
//
//  Created by Ronan Mak on 19/3/2022.
//

import Firebase

struct CommentService {
    
    static func uploadComment(comment: String, postID: String, user: User, completion: @escaping(FirestoreCompletion)) {
        
        print("\(comment)")
        
        let data: [String: Any] = ["userID": user.userID,
                                   "comment": comment,
                                   "timestamp": Timestamp(date: Date()),
                                   "username": user.username,
                                   "profileImageUrl": user.profileImageUrl]
        
        COLLECTION_POSTS.document(postID).collection("comments").addDocument(data: data, completion: completion)
        
    }
    
    static func fetchComment() {
        
    }
}
