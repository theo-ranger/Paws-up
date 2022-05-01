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
        
        print("loginviewmodel called")
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
        do{
            try Auth.auth().signOut()
            
        }catch{
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
    
    deinit{
        Auth.auth().removeStateDidChangeListener(handler)
    }
}

class PoostViewModel: ObservableObject {
    @Published var posts: Array<Coontent> = []
//    var content1 = Coontent(id: UUID().uuidString, timeStamp: NSDate().timeIntervalSince1970, title: "title", userName: "username", image: "parrot")
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    init() {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
//        posts.append(content1)
        ref = Database.database().reference()

        let storage = Storage.storage()
        
        storageRef = storage.reference()
        
    }
    
    func addPost(userName: String, title: String, image: String) {
        print(userName)
        ref.child("posts").child(title).setValue(["id": UUID().uuidString, "timeStamp": String(NSDate().timeIntervalSince1970), "username": userName, "image": image])
        fetchPosts()
    }
    
    func fetchPosts() {
        
        
        ref.child("posts").getData(completion:  { error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return;
          }
            let dict = snapshot.value as? Dictionary<String, Any> ?? nil;
            if (dict == nil) {
                return
            }
            let dic = dict as! Dictionary<String, Dictionary<String, String>>
            var allPosts: [Coontent] = []
            for (key, val) in dic {
                // Create a reference to the file you want to download
                let islandRef = self.storageRef.child("GettyImages-1175550351.jpg")

                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                  if let error = error {
                    // Uh-oh, an error occurred!
                      print("error")
                  } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)!
                      print("succ")
                  }
                }
                
                var content = Coontent(id: val["id"]!, timeStamp: val["timeStamp"]!, title: key, userName: val["username"]!, image: val["image"]!)
                allPosts.append(content)
                allPosts.sort {
                    $0.timeStamp < $1.timeStamp
                }
                self.posts = allPosts
            }

        });
    }
    
    struct Coontent: Identifiable {
        var id: String
        var timeStamp: String
        var title: String
        var userName: String
        var image: String
    }
}

class PostViewModel: ObservableObject {
    
    static let imageAddresses = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    
    static let titles = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    
    static let userNames = ["Prince", "Ella", "Leah", "Irene", "Alfred", "Franklin"]
    
    static let userImageAddresses = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    
    static let articleContents = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    
    static let timeStamps = ["", "", "", "", "", ""]
    
    static let contents: Array<Content> = createContentArray()
    
    static func createContentArray() -> Array<Content> {
        var contents: Array<Content> = []
        
        for i in 0..<6 {
            contents.append(Content(title: PostViewModel.imageAddresses[i],
                                    articleContent: PostViewModel.articleContents[i],
                                    imageAddress: PostViewModel.imageAddresses[i],
                                    userName: PostViewModel.userNames[i],
                                    userImageAddress: PostViewModel.userImageAddresses[i],
                                    timeStamp: PostViewModel.timeStamps[i]))
        }
        
        return contents
    }
    
    static func createPostContent() -> PostModel<Content> {
        PostModel<Content>(numberOfPosts: 6) { index in
            PostViewModel.contents[index]
        }
    }
    
    @Published private var model: PostModel<Content> = PostViewModel.createPostContent()
    
    var posts: Array<PostModel<Content>.Post> {
        model.posts
    }
    
    struct Content {
        var title: String
        var articleContent: String
        var imageAddress: String
        var userName: String
        var userImageAddress: String
        var timeStamp: String
    }
    
    // MARK: -Intent(s)
    
    func like(_ post: PostModel<Content>.Post) {
        model.like(post)
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
