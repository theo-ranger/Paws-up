//
//  HomePageView.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import UIKit
import SwiftUI
import Firebase

/**
  LoginView defines a View for first time users' login actions.
*/
struct LoginView: View {
    @ObservedObject var loginModel: LoginViewModel
    let LIGHT_GREY = Color(red: 239.0/255.0,
                               green: 243.0/255.0,
                               blue: 244.0/255.0,
                               opacity: 1.0)
    
    var body: some View {
           VStack{
               Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 150, height: 150)
                               .clipShape(Circle())
                               .padding(.bottom, 75)
               Text("Log in or Sign up")
                   .font(.largeTitle)
                   .foregroundColor(Color("logo-pink"))
                   .fontWeight(.semibold)
                   .padding(.bottom, 20)
               TextField("Email", text: $loginModel.email)
                   .keyboardType(.emailAddress)
                   .disableAutocorrection(true)
                   .autocapitalization(.none)
                   .padding()
                   .background(LIGHT_GREY)
                   .cornerRadius(5.0)
                   .padding(.bottom, 20)
               SecureField("Password", text: $loginModel.password)
                   .padding()
                   .background(LIGHT_GREY)
                   .cornerRadius(5.0)
                   .padding(.bottom, 20)
               Button(action: {
                   Task {
                       await loginModel.signIn()
                   }
               }){
                   Text("Log In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color("logo-pink"))
                    .cornerRadius(15.0)
                    .padding(.bottom, 20)
               }
               Button(action: {
                   Task {
                       await loginModel.signUp()
                   }
               }){
                   Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color("logo-pink"))
                    .cornerRadius(15.0)
               }
           }.padding()
        }
}

/**
  CardView defines a View for each individual post.
*/
struct CardView: View {
    var postModel: PostViewModel
    var post: Content
    var username: String
    
    @State var liked: Bool
    @State var likeList: [String]
    
    init(postModel: PostViewModel, post: Content, username: String) {
        self.postModel = postModel
        self.post = post
        self.username = username
        liked = post.likedUsers.contains(username)
        likeList = post.likedUsers
    }
    
    var body: some View {
        VStack {
            Image(uiImage: post.image.imageFromBase64!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 170, height: 200, alignment: .center)
                .clipped()
            HStack {
                VStack {
                    Text(post.title).foregroundColor(.black)
                    Text(username).foregroundColor(.black)
                }
                Spacer()
                HStack {
                    Button(action: {
                        liked.toggle()
                        if likeList.contains(username) {
                            likeList = likeList.filter(){$0 != username}
                        } else {
                            likeList.append(username)
                        }
                        postModel.likePost(userName: username, post: post)
                    }, label: {
                        if liked {Image(systemName: "heart.fill")}
                        else {Image(systemName: "heart")}
                    })
                    Text(String(likeList.count))
                }
            }
        }
    }
}

/**
  PostView defines the subview for the Community Tab.
*/
struct PostView: View {
    @ObservedObject var loginModel: LoginViewModel
    @ObservedObject var postModel: PostViewModel
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: { }, label: {
                        Image(systemName: "magnifyingglass").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
                    })
                    Spacer()
                    Button(action: { }, label: {
                        NavigationLink(destination: NewPostView(postModel: postModel, loginModel: loginModel)) {
                            Image(systemName: "square.and.pencil").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
                        }
                    })
                }
                Spacer()
                //FilterBar(labels: $activeLabels)
                // Here's the filter view
                ScrollView {
                    LazyVGrid(columns: [GridItem(spacing: 30), GridItem(spacing: 30)],spacing: 10) {
                        // Show only posts with active labels marked by activeLabels, an @Binding variable.
                        //.filter {$0.tags.contains(where: activeLabels.contains)}
                        ForEach(postModel.posts) { post in
                            NavigationLink(
                                destination:
                                    DetailedPostView(post: post)) {
                                        CardView(postModel: postModel, post: post, username: loginModel.getEmail())
                              }
                        }
                    }
                }
                    .navigationBarHidden(true)
                    .animation(.default, value: true)
            }
        }
    }
}

/**
  HomePageView defines a startar View for the entrance of the app.
*/
struct HomePageView: View {
    var loginModel: LoginViewModel
    var postModel: PostViewModel
    var profileViewModel: ProfileViewModel
    var mapModel: MapViewModel
    
    //@Binding var activeLabels: [String]
    
    var body: some View {
        Spacer()
        HStack{TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            PostView(loginModel: loginModel, postModel: postModel, profileViewModel: profileViewModel).tabItem {
                Image(systemName: "circle.hexagonpath")
                Text("Community")}.tag(1)
            MapView(rescueModel: mapModel, loginModel: loginModel).tabItem {
                Image(systemName: "location")
                Text("Maps")}.tag(2)
            Text("Donation+ View").tabItem {
                Image(systemName: "giftcard")
                Text("Donation+")}.tag(3)
            ProfileView(profileViewModel: profileViewModel, profile: profileViewModel.profile, loginModel: loginModel).tabItem {
                Image(systemName: "person.circle")
                Text("Profile")}.tag(3)
            }.accentColor(Color("logo-pink"))
        }
    }
}

/**
  PostView defines the subview for the Profile Tab.
*/
struct ProfileView: View {
    var profileViewModel: ProfileViewModel
    var profile: ProfileModel.Profile
    var loginModel: LoginViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Spacer()
                    Image("denero").clipShape(Circle())
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("John Denero").font(.system(size: 30))
                    Spacer()
                }
                HStack {
                    Spacer()
                    VStack {
                        Text("2.3k").font(.system(size: 18))
                        Text("Followers").font(.system(size: 14))
                    }
                    Spacer().frame(width: 20)
                    VStack {
                        Text("417").font(.system(size: 18))
                        Text("Following").font(.system(size: 14))
                    }
                    Spacer()
                }
//                Text("Email: " + loginModel.getEmail())
                HStack {
                    Spacer()
                    VStack {
                        Text("Posts").font(.system(size: 14))
                        Rectangle().fill(Color.black).frame(width: 30, height: 1, alignment: .center).offset(y: -10)
                    }
                    Spacer().frame(width: 24)
                    VStack {
                        Text("Liked").font(.system(size: 14))
                        Rectangle().fill(Color.gray).frame(width: 30, height: 1, alignment: .center).offset(y: -10)
                    }
                    Spacer()
                }
//                Button(action: {
//                    Task {
//                        await loginModel.signOut()
//                    }
//                }) {
//                    Text("Log Out")
//                }
            }
        }
    }
}


/**
  NewPostView defines a View for adding new posts.
*/
struct NewPostView: View {
    var postModel: PostViewModel
    var loginModel: LoginViewModel

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage = UIImage(named: "cat-portrait")
    @State private var isImagePickerDisplay = false
    @State private var tagInput: String = ""
    private let tags: [String] = ["Dogs", "Cats", "Adoption"]
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Enter title...", text: $title, onEditingChanged: { (changed) in
                    print("title onEditingChanged - \(changed)")
                })
            }
            
            Section(header: Text("Description")) {
                TextField("Enter description...", text: $description, onEditingChanged: { (changed) in
                    print("description onEditingChanged - \(changed)")
                })
            }
            
            Section(header: Text("Image")) {
                Button("Camera") {
                    self.sourceType = .camera
                    self.isImagePickerDisplay.toggle()
                }
                Button("Photo") {
                    self.sourceType = .photoLibrary
                    self.isImagePickerDisplay.toggle()
                }
            }
            
            Section(header: Text("Tags")) {
                Picker("Selected Tag", selection: $tagInput) {
                    ForEach(tags, id: \.self) {
                        Text($0)
                    }
                }
            }
            Button(action: { addPost(username: loginModel.getEmail(), title: title, description: description, image: selectedImage!, tags: tagInput)}, label: {Text("Publish Post").foregroundColor(Color("logo-pink")).font(.system(size: 20));
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("logo-pink")).sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
        }.navigationTitle("Add Post")
    }
    
    func addPost(username: String, title: String, description: String, image: UIImage, tags: String) {
        postModel.addPost(userName: username, title: title, description: description, image: image, tags: tags)
    }
}

/**
  DetailedPostView defines a View for adding new posts.
*/
struct DetailedPostView: View {
    var post: Content

    var body: some View {
        VStack {
            Text("Title: " + post.title)
            Text("By: " + post.userName)
            Text("Posted on: " + convertToDate(timeStamp: post.timeStamp))
            Text("Description: " + post.description)
            Text(post.timeStamp)
            //Image(uiImage: post.image)
                //.resizable()
                //.aspectRatio(contentMode: .fit)
        }
    }
    // TODO: Resize image

    func convertToDate(timeStamp: String) -> String {
        let date = NSDate(timeIntervalSince1970: Double(timeStamp)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        let dateString = formatter.string(from: date as Date)
        return dateString
    }
}


struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator // confirming the delegate
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}


class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
}

struct View_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(postModel: PostViewModel(), loginModel: LoginViewModel())
        HomePageView(loginModel: LoginViewModel(), postModel: PostViewModel(), profileViewModel: ProfileViewModel(), mapModel: MapViewModel())
    }
}
