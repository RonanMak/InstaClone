//
//  ProfileHeaderViewModel.swift
//  InstaClone
//
//  Created by Ronan Mak on 24/2/2022.
//

import Foundation
import UIKit

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit profile"
        }
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isCurrentUser ? .white : user.isFollowed ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser ? .black : user.isFollowed ? .black : .white
    }
    
    init(user: User) {
        self.user = user
    }
}
