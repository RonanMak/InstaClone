//
//  AuthService.swift
//  InstaClone
//
//  Created by Ronan Mak on 22/2/2022.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let username: String
    let fullname: String
    let profileImage: UIImage
}

struct AuthService {
    
    static func logUserIn(with email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) {
                (result, error) in
                
                if let error = error {
                    print("DEBUG: filed to register user \(error.localizedDescription)")
                    return
                }
                
                guard let userID = result?.user.uid else { return }
                
                let userData: [String: Any] = ["email": credentials.email,
                                           "fullname": credentials.fullname,
                                           "profileImageUrl": imageUrl,
                                           "userID": userID,
                                           "username": credentials.username]
                COLLECTION_USERS.document(userID).setData(userData, completion: completion)
            }
        }
    }
}
