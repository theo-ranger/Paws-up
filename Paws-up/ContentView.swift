//
//  ContentView.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @ObservedObject var loginModel = LoginViewModel()
    
    @ObservedObject var postModel: PoostViewModel

//    @ObservedObject var viewModel: PostViewModel
    
    
    @ObservedObject var profileViewModel: ProfileViewModel
    
    
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
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    
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
                   .background(lightGreyColor)
                   .cornerRadius(5.0)
                   .padding(.bottom, 20)
               SecureField("Password", text: $loginModel.password)
                   .padding()
                   .background(lightGreyColor)
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
    
    @ObservedObject var postModel: PoostViewModel

//    @ObservedObject var viewModel: PostViewModel
    
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
//                            ForEach(viewModel.posts) { post in
//                                NavigationLink(
//                                    destination: ImageView(imageName: post.content.imageAddress).frame(width: 100, height: 200)) {
//                                        CardView(viewModel: viewModel, post: post)
//                                  }
//                            }
                            ForEach(postModel.posts) { post in
                                NavigationLink(
                                    destination: ImageView(imageName: post.image).frame(width: 100, height: 200)) {
                                        CaardView(postModel: postModel, post: post)
                                  }
                            }
                        }
                    }.padding(5)
                        .navigationBarHidden(true)
                        .animation(.default, value: true).onAppear(perform: {postModel.fetchPosts()})
                }
            }.tabItem {
                Image(systemName: "house")
                Text("Home")
                    
            }.tag(1)
            Text("Donation Page").tabItem { Image(systemName: "pawprint.fill")
                Text("Donation") }.tag(2)
            Text("Adoption Page").tabItem { Image(systemName: "bandage")
                Text("Adoption") }.tag(3)
            Text("Report Stray Animals Page").tabItem { Image(systemName: "exclamationmark.bubble.circle")
                Text("Report")}.tag(4)
            Text("Pet Dating Page").tabItem { Image(systemName: "heart")
                Text("Pet Dating")}.tag(5)
        }.accentColor(Color("logo-pink"))
    }
    }
}

struct CaardView: View {
    var postModel: PoostViewModel

    var post: PoostViewModel.Coontent
    

    var body: some View {
        VStack {
            Image(post.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipped()
            Text(post.userName).foregroundColor(.black)
            Text(post.title).foregroundColor(.black)
            Text(post.timeStamp).foregroundColor(.black)
            }
        }
    }

struct CardView: View {
    var viewModel: PostViewModel

    var post: PostModel<PostViewModel.Content>.Post
    
    @State var didLike: Bool = true

    var body: some View {
        VStack {
            Image(post.content.imageAddress)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipped()
            HStack{
                Text(post.content.userName).foregroundColor(.black)
                Spacer()
                Button(action: {
                    didLike = post.liked
                    viewModel.like(post)
                }, label: {
                        didLike ? Image(systemName: "heart")
                        .foregroundColor(Color("logo-pink")) :
                    Image(systemName: "heart.fill")
                    .foregroundColor(Color("logo-pink"))
                })
                Text(String(post.likes))
                    .foregroundColor(Color("logo-pink"))
            }
            Text(post.content.title).foregroundColor(.black)
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
//                Text(profile.userName)
//                    .bold()
//                    .font(.title)
//                Text("Birthyear: " + profile.birthYear)
//                Text("Favorite Animal: " + profile.favoriteAnimal)
//                Text("Email: " + profile.email)
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
    var postModel: PoostViewModel
    var body: some View {
        penIcon.frame(alignment: Alignment.topTrailing)
        Spacer()
    }
    
    var penIcon: some View {
        Button(action: { }, label: {
            NavigationLink(destination: NewPoostView(postModel: postModel, loginModel: loginModel)) {
                Image(systemName: "square.and.pencil").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
            }
        })
    }
}

struct NewPoostView: View {
    var postModel: PoostViewModel
    var loginModel: LoginViewModel

    @State private var title: String = ""
    var animal = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"]
    @State private var selected = "cat-portrait"
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Title: \(title)")
            TextField("Enter title...", text: $title, onEditingChanged: { (changed) in
                print("title onEditingChanged - \(changed)")
            }).padding(.all).textFieldStyle(RoundedBorderTextFieldStyle()).frame(height: 50)
            Text("Image:")
            Picker("Please choose an animal", selection: $selected) {
                            ForEach(animal, id: \.self) {
                                Text($0)
                            }
                        }
            Spacer()
            Button(action: { addPost(username: loginModel.getEmail(), title: title, image: selected)}, label: {Text("Publish Post").foregroundColor(Color("logo-pink")).font(.system(size: 20));
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("logo-pink"))
        }.padding()
    }
    
    func addPost(username: String, title: String, image: String) {
        postModel.addPost(userName: username, title: title, image: image)
    }
}

struct NewPostView: View {
    @State private var title: String = ""
    @State private var mainContent: String = ""
    @State private var hashtag: String = ""
    @State private var imagesNewPost: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Title: \(title)")
            TextField("Enter title...", text: $title, onEditingChanged: { (changed) in
                print("title onEditingChanged - \(changed)")
            }).padding(.all).textFieldStyle(RoundedBorderTextFieldStyle()).frame(height: 50)
            
            Text("Post content: \(mainContent)")
            TextField("Enter your post content...", text: $mainContent, onEditingChanged: { (changed) in
                print("mainContent onEditingChanged - \(changed)")
            }).padding(.all).textFieldStyle(RoundedBorderTextFieldStyle()).frame(height: 50)
            Text("Hashtags: \(hashtag)")
            TextField("Optional: enter hashtags...", text: $hashtag, onEditingChanged: { (changed) in
                print("hashtag onEditingChanged - \(changed)")
            }).padding(.all).textFieldStyle(RoundedBorderTextFieldStyle()).frame(height: 50)
            Button(action: { }, label: {Text("Upload Images").fontWeight(.regular).foregroundColor(Color("logo-pink")).font(.system(size: 20));
                NavigationLink("", destination: NewPostView())//TODO
            }).padding(.horizontal, 0.0).buttonStyle(.bordered).foregroundColor(Color("logo-pink"))
            Text("Selected images: \(imagesNewPost)")
            Spacer()
            Button(action: { }, label: {Text("Publish Post").foregroundColor(Color("logo-pink")).font(.system(size: 20));
                NavigationLink("", destination: NewPostView())//TODO
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("logo-pink"))
        }.padding()
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
    var imageName: String
    
    var body: some View {
        Image(imageName)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        let app = PostViewModel()
        let app = PoostViewModel()

        let profile = ProfileViewModel()
        
        Group {
            ContentView(postModel: app, profileViewModel: profile)
            NewPostView()
        }
    }
}
