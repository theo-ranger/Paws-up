//
//  Paws-upPostModel.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 3/12/22.
//

import Foundation
import SwiftUI

struct PostModel {
    private(set) var posts: Array<Content>
    
    init(postContentArray: Array<Content>) {
        posts = postContentArray
    }
    
    struct Content: Identifiable {
        var id: String
        var timeStamp: String
        var title: String
        var userName: String
        var image: UIImage
        var likedUsers: String
    }
}

struct ProfileModel {
    private(set) var profile: Profile
    
    mutating func edit(_ profile: Profile, _ feature: Int, _ setTo: String) {
        switch feature {
        case 0 :
            self.profile.userName = setTo
        case 1 :
            self.profile.birthYear = setTo
        case 2 :
            self.profile.email = setTo
        case 3 :
            self.profile.favoriteAnimal = setTo
        default :
            return
        }
    }
    
    init(createProfileContent: () -> Profile) {
        let content = createProfileContent()
        
        profile = Profile(userName: content.userName, birthYear: content.birthYear, email: content.email, favoriteAnimal: content.favoriteAnimal)
    }
    
    struct Profile {
        var userName: String
        var birthYear: String
        var email: String
        var favoriteAnimal: String
    }
}


