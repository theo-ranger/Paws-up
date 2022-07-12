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

let path = "posts"

class PostRepository: ObservableObject {
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    @Published var posts: [Content] = []
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    init() {
        fetchPosts()
    }
    
    func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        print("post fetch")
        let db = Firestore.firestore()
        
        db.collection(path).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ PostDataSource.fetchItems()]: \(err)")
                return
            } else {
                let posts = querySnapshot!.documents.map { (document) -> Content in
                    let dict = document.data()
                    return self.parsePost(dict)
                }
                completion(posts)
                self.posts = posts
            }
        }
    }
    
    func fetchPosts() {
        self.fetchItems { resources in
            self.posts.sort {$0.timeStamp > $1.timeStamp}
            print("done")
        }
    }
    
    func parsePost(_ dict: [String: Any]) -> Content {
        let dic = dict as! Dictionary<String, String>
        let dic2 = dict as! Dictionary<String, [String: Bool]>
        
        let post = Content(id: dic["id"]!,
                           timeStamp: dic["timeStamp"]!,
                           title: dic["title"]!,
                           description: dic["description"]!,
                           userName: dic["username"]!,
                           image: dic["image"]!,
                           likedUsers: dic2["likedUsers"]!)
    
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
            "likedUsers": [:]
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func likePost(userName: String, post: Content) {
        let postRef = db.collection("posts").document(post.id)
        postRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let previousPost = self.parsePost(document.data()!)
                    var users = previousPost.likedUsers
                    if let val = users[userName] {
                        if val {
                            users[userName] = false
                        } else {
                            users[userName] = true
                        }
                    } else {
                        users[userName] = true
                    }
                    postRef.updateData([
                        "likedUsers": users
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
