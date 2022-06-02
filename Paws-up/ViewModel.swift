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
    @Published var posts: Array<Content> = []

    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    func addPost(userName: String, title: String, image: UIImage) {
        let uid = UUID().uuidString
//        databaseRef.child("posts").child(title).setValue(["id": uid, "timeStamp": String(NSDate().timeIntervalSince1970), "username": userName])
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data: [
            "id": uid,
            "timeStamp": String(NSDate().timeIntervalSince1970),
            "username": userName,
            "title": title,
            "image": String(image.base64!)
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        print("post added" + userName)
        // Create a reference to the file you want to upload
        let imgRef = storageRef.child(uid)
        let compressed = image.jpegData(compressionQuality: 0.2)
        // Upload the file to the path "images/rivers.jpg"
        _ = imgRef.putData(compressed!, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
            // Uh-oh, an error occurred!
            print("upload error")
            return
          }
        }
        fetchPosts()
    }
    
    func fetchPosts() {
//        DataManager.shared.fetchAll()
        PostDataSource.fetchItems {resources in
            self.posts = PostDataSource.shared.posts
            self.posts.sort {$0.timeStamp < $1.timeStamp}
            print("done")
        }
//        db.collection("posts").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                var allPosts: [Content] = []
//                for document in querySnapshot!.documents {
//                    let dic = document.data() as! Dictionary<String, String>
//                    // Create a reference to the file you want to download
//                    let childRef = self.storageRef.child(dic["id"]!)
//                    print(dic["id"]!)
//                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//                    let image = UIImage(named: "cat-portrait")
//                    childRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                      if let error = error {
//                        // Uh-oh, an error occurred!
//                          print("image fetch error")
//                      } else {
//                        // Data for "images/island.jpg" is returned
//                        let image = UIImage(data: data!)!
//                          var content = Content(id: dic["id"]!, timeStamp: dic["timeStamp"]!, title: dic["title"]!, userName: dic["username"]!, image: image)
//                          allPosts.append(content)
//                          allPosts.sort {
//                              $0.timeStamp < $1.timeStamp
//                          }
//                          self.posts = allPosts
//                      }
//                    }
//                }
//            }
//        }
//        databaseRef.child("posts").getData(completion:  { error, snapshot in
//          guard error == nil else {
//            print(error!.localizedDescription)
//            return;
//          }
//            let dict = snapshot?.value as? Dictionary<String, Any> ?? nil;
//            if (dict == nil) {
//                return
//            }
//            let dic = dict as! Dictionary<String, Dictionary<String, String>>
//            var allPosts: [Content] = []
//            var img: UIImage!
//            for (key, val) in dic {
//                // Create a reference to the file you want to download
//                let childRef = self.storageRef.child(val["id"]!)
//
//                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//                childRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                  if let error = error {
//                    // Uh-oh, an error occurred!
//                      print("error")
//                  } else {
//                    // Data for "images/island.jpg" is returned
//                    let image = UIImage(data: data!)!
//                      img = image
//                      var content = Content(id: val["id"]!, timeStamp: val["timeStamp"]!, title: key, userName: val["username"]!, image: img!)
//                      allPosts.append(content)
//                      allPosts.sort {
//                          $0.timeStamp < $1.timeStamp
//                      }
//                      self.posts = allPosts
//                  }
//                }
//            }
//        });
    }
    
    
    
//    static let contents: Array<Content> = createContentArray()
//
//    static func createContentArray() -> Array<Content> {
//        var contents: Array<Content> = []
//
//        for i in 0..<6 {
//            contents.append(Content(title: PostViewModel.imageAddresses[i],
//                                    articleContent: PostViewModel.articleContents[i],
//                                    imageAddress: PostViewModel.imageAddresses[i],
//                                    userName: PostViewModel.userNames[i],
//                                    userImageAddress: PostViewModel.userImageAddresses[i],
//                                    timeStamp: PostViewModel.timeStamps[i]))
//        }
//
//        return contents
//    }
//
//    static func createPostContent() -> PostModel<Content> {
//        PostModel<Content>(numberOfPosts: 6) { index in
//            PostViewModel.contents[index]
//        }
//    }
//    
//    @Published private var model: PostModel<Content> = PostViewModel.createPostContent()
//
//    // MARK: -Intent(s)
//
//    func like(_ post: PostModel<Content>.Post) {
//        model.like(post)
//    }
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
