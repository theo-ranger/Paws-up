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
        fetchPosts()
    }
    
    func likePost(userName: String, post: PostModel.Content) {
        print(post.likedUsers)
        // Create a reference to the cities collection
        let postRef = db.collection("posts").document(post.id)
        postRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let previousPost = PostDataSource.parsePost(document.data()!)
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
        fetchPosts()
    }
    
    func likeCount(post: PostModel.Content) -> String {
        let likeList = post.likedUsers
        if likeList == "" {
            return "0"
        }
        return String(likeList.filter { $0 == " " }.count + 1)
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
