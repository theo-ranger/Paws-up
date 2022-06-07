//
//  ContentView.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import UIKit
import SwiftUI
import Firebase

struct ContentView: View {
    @ObservedObject var loginModel = LoginViewModel()
    
    @ObservedObject var postModel = PostViewModel()
    
    @ObservedObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            if (loginModel.isLoggedIn) {
                MainView(loginModel: loginModel, postModel: postModel, profileViewModel: profileViewModel)
            } else {
                LoginView(loginModel: loginModel)
            }
        }
        .alert("Error", isPresented: $loginModel.hasError) {
        } message: {
            Text(loginModel.errorMessage)
        }
        .padding()
    }
}


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


struct MainView: View {
    @ObservedObject var loginModel: LoginViewModel
    
    @ObservedObject var postModel: PostViewModel

    @ObservedObject var profileViewModel: ProfileViewModel
    var body: some View {
        Spacer()
        HStack{TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            NavigationView {
                VStack {
                    HStack {
                        Button(action: { }, label: {
                            NavigationLink(destination: ProfileView(viewModel: profileViewModel, profile: profileViewModel.profile, loginModel: loginModel)) {
                                Image(systemName: "person.circle").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
                            }
                        }).frame(alignment: Alignment.topTrailing)
                        Spacer()
                        SearchBar(text: .constant(""))
                        Spacer()
                        NewPostButton(loginModel: loginModel, postModel: postModel)
                    }
                    Spacer()
                    ScrollView {
                        LazyVGrid(columns: [GridItem(spacing: 30), GridItem(spacing: 30)],spacing: 10) {
                            ForEach(postModel.posts) { post in
                                NavigationLink(
                                    destination: ImageView(img: post.image).frame(width: 100, height: 200)) {
                                        CardView(postModel: postModel, post: post, loginModel: loginModel)
                                  }
                            }
                        }
                    }.padding(5)
                        .navigationBarHidden(true)
                        .animation(.default, value: true)
                        // FIXME: Redesign post appearance mechanism
                        .onAppear(perform: {postModel.fetchPosts()})
                }
            }.tabItem {
                Image(systemName: "house")
                Text("Home")}.tag(1)
            Text("Donation Page").tabItem {
                Image(systemName: "pawprint.fill")
                Text("Donation") }.tag(2)
            Text("Adoption Page").tabItem {
                Image(systemName: "bandage")
                Text("Adoption") }.tag(3)
            Text("Report Stray Animals Page").tabItem {
                Image(systemName: "exclamationmark.bubble.circle")
                Text("Report")}.tag(4)
            Text("Pet Dating Page").tabItem {
                Image(systemName: "heart")
                Text("Pet Dating")}.tag(5)
            }.accentColor(Color("logo-pink"))
        }
    }
}


struct CardView: View {
    var postModel: PostViewModel

    var post: PostModel.Content
    
    var loginModel: LoginViewModel
    
    @State var didLike: Bool = true
    
    var body: some View {
        VStack {
            Image(uiImage: post.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipped()
            HStack {
                VStack {
                    Text(post.title).foregroundColor(.black)
                    Text(post.userName).foregroundColor(.black)
                }
                Spacer()
                VStack {
                    Button(action: {
                    postModel.likePost(userName: loginModel.getEmail(), post: post)
                    }, label: {
                        Image(systemName: "heart.fill")
                    })
                    Text(postModel.likeCount(post: post))
                }
            }
        }
    }
}


struct ProfileView: View {
    var viewModel: ProfileViewModel

    var profile: ProfileModel.Profile
    
    var loginModel: LoginViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                CircleImage(image: Image("denero"))
                    .offset(y: -130)
                    .padding(.bottom, -130)
                Text("UID: " + loginModel.getUID())
                Text("Email: " + loginModel.getEmail())
                Button(action: {
                    Task {
                        await loginModel.signOut()
                    }
                }) {
                    Text("Log Out")
                }
            }
        }
    }
}


struct CircleImage: View {
    var image: Image

    var body: some View {
        image
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
    }
}


struct NewPostButton: View {
    var loginModel: LoginViewModel
    var postModel: PostViewModel
    var body: some View {
        penIcon.frame(alignment: Alignment.topTrailing)
        Spacer()
    }
    
    var penIcon: some View {
        Button(action: { }, label: {
            NavigationLink(destination: NewPostView(postModel: postModel, loginModel: loginModel)) {
                Image(systemName: "square.and.pencil").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
            }
        })
    }
}


struct NewPostView: View {
    var postModel: PostViewModel
    var loginModel: LoginViewModel

    @State private var title: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage = UIImage(named: "cat-portrait")
    @State private var isImagePickerDisplay = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Title: \(title)")
            TextField("Enter title...", text: $title, onEditingChanged: { (changed) in
                print("title onEditingChanged - \(changed)")
            }).padding(.all).textFieldStyle(RoundedBorderTextFieldStyle()).frame(height: 50)
            Text("Image:")
            Image(uiImage: selectedImage!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 300, height: 300)
            Button("Camera") {
                self.sourceType = .camera
                self.isImagePickerDisplay.toggle()
            }.padding()
            
            Button("Photo") {
                self.sourceType = .photoLibrary
                self.isImagePickerDisplay.toggle()
            }.padding()
            Spacer()

            Button(action: { addPost(username: loginModel.getEmail(), title: title, image: selectedImage!)}, label: {Text("Publish Post").foregroundColor(Color("logo-pink")).font(.system(size: 20));
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("logo-pink")).sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
        }.padding()
    }
    
    func addPost(username: String, title: String, image: UIImage) {
        postModel.addPost(userName: username, title: title, image: image)
    }
}


struct SearchBar: View {
    @Binding var text: String
 
    @State private var isEditing = false
 
    var body: some View {
        HStack {
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 5)
                .onTapGesture {
                    self.isEditing = true
                }
 
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
 
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default, value: true)
            }
        }
    }
}


struct ImageView: View {
    var img: UIImage
    
    var body: some View {
        Image(uiImage: img)
    }
    // TODO: Resize image
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let app = PostViewModel()

        let profile = ProfileViewModel()
        
        ContentView(postModel: app, profileViewModel: profile)
    }
}
