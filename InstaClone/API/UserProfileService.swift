//
//  UserProfileService.swift
//  InstaClone
//
//  Created by Ronan Mak on 23/2/2022.
//

import Foundation
import Firebase



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
}
