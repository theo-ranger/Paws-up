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
import FirebaseFunctions

let path = "posts"

class PostRepository: ObservableObject {
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    lazy var functions = Functions.functions()
    
    @Published var posts: [Content] = []
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    init() {
        fetchPosts()
    }
    
    func partialFetchItems(inputArray: [String]) {
        db.collection(path).whereField("tags", arrayContainsAny: inputArray)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let posts = querySnapshot!.documents.map { (document) -> Content in
                        let dict = document.data()
                        return self.parsePost(dict)!
                    }
                    self.posts = posts
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
        }
    }

    
    func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        print("post fetch")        
        db.collection(path).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ PostDataSource.fetchItems()]: \(err)")
                return
            } else {
                let posts = querySnapshot!.documents.map { (document) -> Content in
                    let dict = document.data()
                    return self.parsePost(dict)!
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
    
    func parsePost(_ dict: [String: Any]) -> Content? {
        guard let likedU = dict["likedUsers"] as? [String] else {
            return nil
        }
        
        guard let tags = dict["tags"] as? [String] else {
            return nil
        }
        
        let post = Content(id: dict["id"] as? String ?? "",
                           timeStamp: dict["timeStamp"] as? String ?? "",
                           title: dict["title"] as? String ?? "",
                           description: dict["description"] as? String ?? "",
                           userName: dict["username"] as? String ?? "",
                           image: dict["image"] as? String ?? "",
                           likedUsers: likedU,
                           tags: tags)
    
        return post
    }
    
    func addPost(userName: String, title: String, description: String, image: UIImage, tags: String) {
        let uid = UUID().uuidString
        // Add a new document with a generated ID
        db.collection("posts").document(uid).setData([
            "id": uid,
            "timeStamp": String(NSDate().timeIntervalSince1970),
            "username": userName,
            "title": title,
            "description": description,
            "image": String(image.base64!),
            "likedUsers": [],
            "tags": [tags]
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        fetchPosts()
    }
    
    func likePost(userName: String, post: Content) {
        let postRef = db.collection("posts").document(post.id)
        postRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let previousPost = self.parsePost(document.data()!)
                var users = previousPost!.likedUsers
                if users.contains(userName) {
                    users = users.filter(){$0 != userName}
                } else {
                    users.append(userName)
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
