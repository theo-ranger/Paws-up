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
    
    init(numberOfPosts: Int, createPostContent: (Int) -> PostContent) {
        posts = Array<Post>()
        
        for index in 0..<numberOfPosts {
            let content = createPostContent(index)
            posts.append(Post(likes: 0, liked: false, id: index, content: content))
        }
    }
    
    struct Post: Identifiable {
        var likes: Int
        var liked: Bool
        var id: Int
        var content: PostContent
    }
}
