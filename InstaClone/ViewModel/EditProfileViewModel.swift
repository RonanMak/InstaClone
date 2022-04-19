//
//  EditProfileViewModel.swift
//  InstaClone
//
//  Created by Ronan Mak on 9/4/2022.
//
//NEW
import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    
    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Name"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        case .username: return user.username
        case .fullname: return user.fullname
        }
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
