//
//  Paws-upPostViewModel.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 3/12/22.
//

import SwiftUI

class PostViewModel: ObservableObject {
    
    static let imageAddresses = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    
    static let titles = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    
    static let userNames = ["Prince", "Ella", "Leah", "Irene", "Alfred", "Franklin"]
    
    static let userImageAddresses = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    
    static let articleContents = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    
    static let timeStamps = ["", "", "", "", "", ""]
    
    static let contents: Array<Content> = createContentArray()
    
    static func createContentArray() -> Array<Content> {
        var contents: Array<Content> = []
        
        for i in 0..<6 {
            contents.append(Content(title: PostViewModel.imageAddresses[i],
                                    articleContent: PostViewModel.articleContents[i],
                                    imageAddress: PostViewModel.imageAddresses[i],
                                    userName: PostViewModel.userNames[i],
                                    userImageAddress: PostViewModel.userImageAddresses[i],
                                    timeStamp: PostViewModel.timeStamps[i]))
        }
        
        return contents
    }
    
    static func createPostContent() -> PostModel<Content> {
        PostModel<Content>(numberOfPosts: 6) { index in
            PostViewModel.contents[index]
        }
    }
    
    @Published private var model: PostModel<Content> = PostViewModel.createPostContent()
    
    var posts: Array<PostModel<Content>.Post> {
        model.posts
    }
    
    struct Content {
        var title: String
        var articleContent: String
        var imageAddress: String
        var userName: String
        var userImageAddress: String
        var timeStamp: String
    }
    
    // MARK: -Intent(s)
    
    func like(_ post: PostModel<Content>.Post) {
        model.like(post)
    }
}

class ProfileViewModel: ObservableObject {
    static let profileArray = ["John DeNero", "1978", "denero@berkeley.edu", "Dog"]
    
    static let contents: ProfileModel.Profile = createContent()
    
    static func createContent() -> ProfileModel.Profile {
        ProfileModel.Profile(userName: profileArray[0],
                             birthYear: profileArray[1],
                             email: profileArray[2],
                             favoriteAnimal: profileArray[3])
    }
    
    static func createProfile() -> ProfileModel {
        ProfileModel() {
            ProfileViewModel.contents
        }
    }
    
    @Published private var model: ProfileModel = ProfileViewModel.createProfile()
    
    var profile: ProfileModel.Profile {
        model.profile
    }
    
    // MARK: -Intent(s)
    
    func edit(_ profile: ProfileModel.Profile, _ feature: Int, _ setTo: String) {
        model.edit(profile, feature, setTo)
    }
}