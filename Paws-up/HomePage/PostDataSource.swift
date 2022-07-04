//
//  PostDataSource.swift
//  Paws-up
//
//  Created by 那桐 on 6/1/22.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

let postDataSource = "posts"

class PostDataSource: DataSource {
    static let shared = PostDataSource()
    
    static var storageRef = Storage.storage().reference()
    
    var posts: Array<PostModel.Content> = []
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        print("post fetch")
        let db = Firestore.firestore()
        
        db.collection(postDataSource).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ PostDataSource.fetchItems()]: \(err)")
                return
            } else {
                let posts = querySnapshot!.documents.map { (document) -> PostModel.Content in
                    let dict = document.data()
                    return parsePost(dict)
                }
                completion(posts)
                PostDataSource.shared.posts = posts
            }
        }
    }
    
    
    static func parsePost(_ dict: [String: Any]) -> PostModel.Content {
        let dic = dict as! Dictionary<String, String>
        // Create a reference to the file you want to download
        print(dic["id"]!)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        var image = UIImage(named: "cat-portrait")
        image = dic["image"]?.imageFromBase64
        
        let post = PostModel.Content(id: dic["id"]!,
                           timeStamp: dic["timeStamp"]!,
                           title: dic["title"]!,
                           description: dic["description"]!,
                           userName: dic["username"]!,
                           image: image!,
                           likedUsers: dic["likedUsers"]!)
        
        return post
    }
}
