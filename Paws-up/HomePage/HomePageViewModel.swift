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
import Combine

class LoginViewModel: ObservableObject {
    
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
    @Published var posts: [Content] = []
    @Published var postRepository = PostRepository()
    
    private var cancellables: Set<AnyCancellable> = []

    private var postModel: PostModel = PostModel()
    
    init() {
        postRepository.$posts
            .assign(to: \.posts, on: self)
            .store(in: &cancellables)
    }
    
    func fetchPosts() {
        postRepository.fetchPosts()
    }
    
    func addPost(userName: String, title: String, description: String, image: UIImage, tags: String) {
        postRepository.addPost(userName: userName, title: title, description: description, image: image, tags: tags)
    }
    
    func likePost(userName: String, post: Content) {
        postRepository.likePost(userName: userName, post: post)
    }
}

class FilteredPostViewModel: ObservableObject {
    @Published var posts: [Content] = []
    @Published var postRepository = PostRepository()
    
    private var cancellables: Set<AnyCancellable> = []

    private var postModel: PostModel = PostModel()
    
    init() {
        postRepository.$posts
            .assign(to: \.posts, on: self)
            .store(in: &cancellables)
    }
    
    func fetchPosts() {
        postRepository.partialFetchItems(inputArray: [])
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
