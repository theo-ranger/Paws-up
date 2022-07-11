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

struct PostModel {
    
    struct Content: Identifiable {
        var id: String
        var timeStamp: String
        var title: String
        var description: String
        var userName: String
        var image: UIImage
        var likedUsers: String
    }
    
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    // MARK: -Intent(s)
    
    func addPost(userName: String, title: String, description: String, image: UIImage) {
        let uid = UUID().uuidString
        // Add a new document with a generated ID
        db.collection("posts").document(uid).setData([
            "id": uid,
            "timeStamp": String(NSDate().timeIntervalSince1970),
            "username": userName,
            "title": title,
            "description": description,
            "image": String(image.base64!),
            "likedUsers": ""
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func likeCount(post: PostModel.Content) -> String {
        let likeList = post.likedUsers
        if likeList == "" {
            return "0"
        }
        return String(likeList.filter { $0 == " " }.count + 1)
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


