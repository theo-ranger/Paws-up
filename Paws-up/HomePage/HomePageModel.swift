//
//  Paws-upPostModel.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 3/12/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

struct Content: Identifiable, Codable {
    var id: String
    var timeStamp: String
    var title: String
    var description: String
    var userName: String
    var image: String
    var likedUsers: [String]
    var tags: [String]
}

//var currentUser: Profile?
var currentUser = Profile(id: "A4E7D540-54CF-48A1-B5D4-FC383E87B01A", profilePic: "abcd", background: "abcd", name: "lala", followers: ["a", "b"], following: ["c", "d"], posts: ["1","2"])

var testUser = Profile(id: "9B8810FB-F4CD-4716-955D-DAEB25662036", profilePic: "abcd", background: "abcd", name: "jaja", followers: ["a", "b"], following: ["c", "d"], posts: ["1","2"])

struct PostModel {
    
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
