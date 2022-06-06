//
//  Paws-upPostViewModel.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 3/12/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

@MainActor class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    var currentUser : User?
    var curr_email = ""
    
    private var handler = Auth.auth().addStateDidChangeListener{_,_ in }
    var ref = Database.database().reference()
    
    init() {
        handler = Auth.auth().addStateDidChangeListener{ auth,user in
            if user != nil {
                self.isLoggedIn = true
                self.currentUser = Auth.auth().currentUser
            } else {
                self.isLoggedIn = false
                self.currentUser = nil
            }
        }
    }
    
    func signIn() async {
        hasError = false
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func signUp() async {
        hasError = false
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            curr_email = email
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() async {
        hasError = false
        do {
            try Auth.auth().signOut()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
        
    }
    
    func getEmail() -> String {
        if currentUser != nil {
            return (currentUser?.email!)!
        } else {
            return ""
        }
    }
    
    func getUID() -> String {
        if currentUser != nil {
            return (currentUser?.uid)!
        } else {
            return ""
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(handler)
    }
}

class PostViewModel: ObservableObject {
    @Published var posts: Array<PostModel.Content> = []

    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    func fetchPosts() {
        PostDataSource.fetchItems { resources in
            self.posts = PostDataSource.shared.posts
            self.posts.sort {$0.timeStamp > $1.timeStamp}
            print("done")
        }
    }
    
    
    // MARK: -Intent(s)
    
    func addPost(userName: String, title: String, image: UIImage) {
        let uid = UUID().uuidString
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data: [
            "id": uid,
            "timeStamp": String(NSDate().timeIntervalSince1970),
            "username": userName,
            "title": title,
            "image": String(image.base64!),
            "likedUsers": ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        print("post added" + userName)
        fetchPosts()
    }
    
    func likePost(userName: String, post: PostModel.Content) {
        // Create a reference to the cities collection
        let postRef = db.collection("posts")

        // Create a query against the collection.
        let query = postRef.whereField("id", isEqualTo: post.id)
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    var previousPost: PostModel.Content = PostDataSource.parsePost(document.data())
                    let newLikedUsers = previousPost.likedUsers + " " + userName
                    self.db.collection("posts").document(document.documentID).updateData([
                        "likedUsers": newLikedUsers
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document modified with ID: \(document.documentID)")
                        }
                    }
                }
            }
        }
    }
    
//    func like() {
//
//    }
    
    // func share() {
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

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 0.2)?.base64EncodedString()
    }
}

extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
