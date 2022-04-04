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
        let chosenIndex = index(of: post)
        
        if (posts[chosenIndex].liked) {
            posts[chosenIndex].likes = posts[chosenIndex].likes - 1
            posts[chosenIndex].liked.toggle()
        } else {
            posts[chosenIndex].likes = posts[chosenIndex].likes + 1
            posts[chosenIndex].liked.toggle()
        }
    }
    
    func index(of post: Post) ->Int {
        for index in 0..<posts.count {
            if posts[index].id == post.id {
                return index
            }
        }
        return 0
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
