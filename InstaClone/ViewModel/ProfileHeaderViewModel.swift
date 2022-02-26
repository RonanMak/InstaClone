//
//  ProfileHeaderViewModel.swift
//  InstaClone
//
//  Created by Ronan Mak on 24/2/2022.
//

import Foundation

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: String {
        return user.profileImageUrl
    }
    
    init(user: User) {
        self.user = user
    }
}
