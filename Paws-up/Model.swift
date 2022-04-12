//
//  Paws-upPostModel.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 3/12/22.
//

import Foundation
import SwiftUI

struct PostModel<PostContent> {
    private(set) var posts: Array<Post>
    
    mutating func like(_ post: Post) {
        if let chosenIndex = posts.firstIndex(where: { $0.id == post.id }) {
            if (posts[chosenIndex].liked) {
                posts[chosenIndex].likes = posts[chosenIndex].likes - 1
                posts[chosenIndex].liked.toggle()
            } else {
                posts[chosenIndex].likes = posts[chosenIndex].likes + 1
                posts[chosenIndex].liked.toggle()
            }
        }
    }
    
    init(numberOfPosts: Int, createPostContent: (Int) -> PostContent) {
        posts = Array<Post>()
        
        for index in 0..<numberOfPosts {
            let content = createPostContent(index)
            posts.append(Post(likes: 0, liked: false, id: index, content: content))
        }
    }
    
    struct Post: Identifiable {
        var likes: Int = 0
        var liked: Bool = false
        var id: Int
        var content: PostContent
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
