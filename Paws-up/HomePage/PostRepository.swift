//
//  PostRepository.swift
//  Paws-up
//
//  Created by 那桐 on 6/1/22.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

let postDataSource = "posts"

class PostRepository: DataSource {
    static let shared = PostRepository()
    
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    @Published var posts: [PostModel.Content] = []
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
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
                shared.posts = posts
            }
        }
    }
    
    func fetchPosts() {
        PostRepository.fetchItems { resources in
            self.posts = PostRepository.shared.posts
            self.posts.sort {$0.timeStamp > $1.timeStamp}
            print("done")
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
    
    func likePost(userName: String, post: PostModel.Content) {
        print(post.likedUsers)
        // Create a reference to the cities collection
        let postRef = db.collection("posts").document(post.id)
        postRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let previousPost = PostRepository.parsePost(document.data()!)
                    let users = previousPost.likedUsers
                    var newLikedUsers = ""
                    if users.contains(userName) {
                        var arr = users.components(separatedBy: " ")
                        if let index = arr.firstIndex(of: userName) {
                            arr.remove(at: index)
                        }
                        newLikedUsers = arr.joined(separator:" ")
                    } else if users != "" {
                        newLikedUsers = users + " " + userName
                    } else {
                        newLikedUsers = userName
                    }
                    postRef.updateData([
                        "likedUsers": newLikedUsers
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document modified with ID: \(document.documentID)")
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
    }
}
