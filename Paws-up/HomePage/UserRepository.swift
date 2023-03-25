//
//  UserRepository.swift
//  Paws-up
//
//  Created by Coco Ma on 2/26/23.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit
import FirebaseFunctions

let path1 = "users"

class UserRepository: ObservableObject {
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    lazy var functions = Functions.functions()
    
    @Published var users: [Profile] = []
    
    init() {
        fetchUsers()
    }
    
    func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        print("user fetch")
        db.collection(path1).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ UserDataSource.fetchItems()]: \(err)")
                return
            } else {
                let users = querySnapshot!.documents.map { (document) -> Profile in
                    let dict = document.data()
                    return self.parseUser(dict)!
                }
                completion(users)
                self.users = users
            }
        }
    }
    
    func fetchUsers() {
        self.fetchItems { resources in
            self.users
            print("done")
        }
    }
    
    func parseUser(_ dict: [String: Any]) -> Profile? {
        guard let followers = dict["followers"] as? [String] else {
            return nil
        }
        
        guard let following = dict["following"] as? [String] else {
            return nil
        }
        
        guard let posts = dict["posts"] as? [String] else {
            return nil
        }
        
        let user = Profile(id: dict["id"] as? String ?? "",
                           profilePic: dict["profilePic"] as? String ?? "",
                           background: dict["background"] as? String ?? "",
                           name: dict["name"] as? String ?? "",
                           followers: followers,
                           following: following,
                           posts: posts)
    
        return user
    }
    
    func addUser(name: String, background: UIImage, profilePic: UIImage) {
        let uid = UUID().uuidString
        // Add a new document with a generated ID
        db.collection("users").document(uid).setData([
            "id": uid,
            "profilePic": String(profilePic.base64!),
            "background": String(background.base64!),
            "name": name,
            "followers": [],
            "following": [],
            "posts": []
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        fetchUsers()
    }
    
    func follow(name: String, user: Profile) {
        let userRef = db.collection("users").document(user.id)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let user = self.parseUser(document.data()!)
                var following = user!.following
                if following.contains(name) {
                    following = following.filter(){$0 != name}
                } else {
                    following.append(name)
                }
                userRef.updateData([
                    "following": following
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
