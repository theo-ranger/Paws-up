//
//  HomePageView.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import UIKit
import SwiftUI
import Firebase
import CoreLocation
import MapKit
import MapItemPicker
import LocationPicker

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
                   .foregroundColor(Color("Logo-Pink"))
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
                    .background(Color("Logo-Pink"))
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
                    .background(Color("Logo-Pink"))
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
                .frame(width: (UIScreen.main.bounds.size.width / 2) - 30, height: (UIScreen.main.bounds.size.width / 2), alignment: .center)
                .clipped()
                .cornerRadius(20)
            Text(post.title).foregroundColor(.red)
            HStack {
                Text(username).foregroundColor(.black)
//                Spacer()
                HStack {
                    Button(action: {
                        liked.toggle()
                        if likeList.contains(username) {
                            likeList = likeList.filter(){$0 != username}
                        } else {
                            likeList.append(username)
                        }
                        postModel.likePost(userName: username, post: post)
                    }) {
                        if liked {Image(systemName: "heart.fill").foregroundColor(.red)}
                        else {Image(systemName: "heart").foregroundColor(.red)}
                        
                    }
                    Text(String(likeList.count)).foregroundColor(.red)
                }
            }
        }
    }
}


// TODO: make search case insensitive
struct SearchView: View {
    @ObservedObject var postModel: PostViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            Text("")
                .searchable(text: $searchText)
            Button(action: {
                postModel.postRepository.partialFetchItems_copy(inputString: searchText)
            }, label: {
                Text("Search for \(searchText)")
            })
            Spacer()
        }.navigationBarItems(trailing: Button(action: {
            postModel.postRepository.fetchPosts()
        }, label: {
            Text("Reset Search")
        }))
    }
}

/**
  PostView defines the subview for the Community Tab.
*/
struct PostView: View {
    @ObservedObject var loginModel: LoginViewModel
    @ObservedObject var postModel: PostViewModel
    var profileViewModel: ProfileViewModel
    var mapModel: MapViewModel
    var userModel: UserViewModel
    
    @State private var navigateTo: AnyView?
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(
                       destination:
                           SearchView(postModel: postModel)) {
                               Image(systemName: "magnifyingglass")
                                   .foregroundColor(Color("Logo-Pink"))
                                   .padding()
                                   .font(.system(size: 25))
                     }
                    Spacer()
                    Menu {
                        Button(action: {
                            navigateTo = AnyView(NewPostView(postModel: postModel, loginModel: loginModel, userModel: userModel))
                            isActive = true
                        }, label: {
//                            NavigationLink(destination: NewPostView(postModel: postModel, loginModel: loginModel)) {
                                Text("New Post")
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(Color("Logo-Pink"))
//                            }
                        })
                        Button(role: .destructive) {
                            navigateTo = AnyView(NewReportView1(mapModel: mapModel, loginModel: loginModel))
                            isActive = true
                        } label: {
                            Text("Report Lost Pet")
                            Image(systemName: "exclamationmark.bubble")
                        }
                        
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color("Logo-Pink"))
                            .padding()
                            .font(.system(size: 25))
                    }.background(
                        NavigationLink(destination: self.navigateTo, isActive: $isActive) {
                            EmptyView()
                        })

                }
                Spacer()
                //FilterBar(labels: $activeLabels)
                // Here's the filter view
                ScrollView {
                    LazyVGrid(columns: [GridItem(spacing: -5), GridItem(spacing: 5)],spacing: 20) {
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
                }.refreshable {
                    print("Do your refresh work here")
                }
                .navigationBarHidden(true)
                .animation(.default, value: true)
            }
        }
    }
}

/**
  HomePageView defines a starter View for the entrance of the app.
*/
struct HomePageView: View {
    var loginModel: LoginViewModel
    var postModel: PostViewModel
    var profileViewModel: ProfileViewModel
    var mapModel: MapViewModel
    var userModel: UserViewModel
    
    //@Binding var activeLabels: [String]
    
    var body: some View {
        Spacer()
        HStack{TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            PostView(loginModel: loginModel, postModel: postModel, profileViewModel: profileViewModel, mapModel: mapModel, userModel: userModel).tabItem {
                Image(systemName: "circle.hexagonpath")
                Text("Community")}.tag(1)
//            MapTestView(place: [IdentifiablePlace(id: UUID(), lat: 37.871684, long: -122.259934)], region: MKCoordinateRegion(
//                center: CLLocationCoordinate2D(latitude: 37.334_900,
//                                               longitude: -122.009_020),
//                latitudinalMeters: 750,
//                longitudinalMeters: 750))
            MapView(rescueModel: mapModel, loginModel: loginModel)
                .tabItem {
                Image(systemName: "location")
                Text("Maps")}.tag(2)
            Text("Donation+ View").tabItem {
                Image(systemName: "giftcard")
                Text("Donation+")}.tag(3)
            ProfileView(profileViewModel: profileViewModel, profile: profileViewModel.profile, loginModel: loginModel, postModel: postModel).tabItem {
                Image(systemName: "person.circle")
                Text("Profile")}.tag(3)
            }.accentColor(Color("Logo-Pink"))
                .onAppear {
                // correct the transparency bug for Tab bars
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                // correct the transparency bug for Navigation bars
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithOpaqueBackground()
                UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            }
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
    var postModel: PostViewModel
    
    var placeholder: [Content] = [Content(id: "testID", timeStamp: "2344567", title: "testTitle", description: "no description", userName: "fake user", image: "image1", likedUsers: [], tags: [])]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Image("profilebg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(0.8)
                        .overlay(
                            Image("denero").clipShape(Circle())
                                .offset(y: 80)
                        )
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
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
                    VStack {
                        HStack {
                            ForEach(placeholder) { post in
                                NavigationLink(
                                    destination:
                                        DetailedPostView(post: post)) {
                                            Image("image1")
                                                .resizable()
                                                .aspectRatio(1.0, contentMode: .fit)
                                                .clipped()
                                        }
                            }
                        }
                        HStack {
                            Image("image4")
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .clipped()
                            Image("image5")
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .clipped()
                            Image("image6")
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .clipped()
                        }
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
}


/**
  NewPostView defines a View for adding new posts.
*/
struct NewPostView: View {
    var postModel: PostViewModel
    var loginModel: LoginViewModel
    var userModel: UserViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage = UIImage(named: "cat-portrait")
    @State private var isImagePickerDisplay = false
    @State private var tagInput: String = ""
    private let tags: [String] = ["Dogs", "Cats", "Adoption"]
    @State var followed = false
    
    var btnBack : some View { Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                    Image("vector") // set image here
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                    }
                }
            }
    
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
            Button(action: { addPost(username: loginModel.getEmail(), title: title, description: description, image: selectedImage!, tags: tagInput)}, label: {Text("Publish Post").foregroundColor(Color("Logo-Pink")).font(.system(size: 20));
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("Logo-Pink")).sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
            
            Button(action: { addUser(name: "lalal", background: selectedImage!, profilePic: selectedImage!)}, label: {Text("user").foregroundColor(Color("Logo-Pink")).font(.system(size: 20));
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("Logo-Pink")).sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
            Button(action: { addUser(name: "blabla", background: selectedImage!, profilePic: selectedImage!)}, label: {Text("user1").foregroundColor(Color("Logo-Pink")).font(.system(size: 20));
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("Logo-Pink")).sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
            
//            Button(action: {
//                follow(name: "jaja", user: currentUser)
//                followed = !followed
//            }) {
//                if followed {Text("following")}
//                else {Text("follow").foregroundColor(Color("Logo-Pink")).font(.system(size: 20))}
//            }
                     
            
        }.navigationTitle("Add Post")
            .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: btnBack)
    }
    
    func addPost(username: String, title: String, description: String, image: UIImage, tags: String) {
        postModel.addPost(userName: username, title: title, description: description, image: image, tags: tags)
    }
    func addUser(name: String, background: UIImage, profilePic: UIImage) {
        userModel.addUser(name: name, background: background, profilePic: profilePic)
    }
    func follow(followee: Profile, follower: Profile) {
        userModel.follow(followee: followee, follower: follower)
    }
    
}

/**
  NewReportView defines a View for adding new reports.
*/
struct NewReportView1: View {

    var mapModel: MapViewModel
    var loginModel: LoginViewModel

    @State private var navigateTo: AnyView?
    @State private var selectedDate: Date = Date()
    @State private var title: String = ""
    @State private var isActive = false

    @State private var bookImage = UIImage(named: "book")
    @State private var petName: String = ""
    @State var clicked = [true, false, false]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var btnBack : some View { Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                    Image("vector") // set image here
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                    }
                }
            }

    var body: some View {
        GeometryReader { g in
            VStack {
                Text("Sorry to hear about that")
                    .font(.system(size: g.size.width * 0.05, weight: .bold, design: .default))
                Text("")
                Text("We are here to help you find your pet!")
                    .font(.system(size: g.size.width * 0.032))
                Image("woman-with-dog")
                        .resizable()
                        .scaledToFill()
                        .frame(width: g.size.width * 0.32, height: g.size.width * 0.32)
                ZStack {
                    VStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 220, height: 2)
                        Text("d")
                            .font(.system(size: 9, design: .default))
                            .opacity(0)
                    }
                    HStack {
                        Spacer()
                        VStack {
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 2)
                                .background(Circle().foregroundColor(Color("Logo-Pink")))
                                .frame(width: g.size.width * 0.032, height: g.size.width * 0.032)
                            Text("Basic Info")
                                .font(.system(size: g.size.width * 0.032))
                                .foregroundColor(Color("Logo-Pink"))
                        }
                        Spacer()
                        VStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: g.size.width * 0.032, height: g.size.width * 0.032)
                            Text("Pet Info")
                                .font(.system(size: g.size.width * 0.032))
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                        VStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: g.size.width * 0.032, height: g.size.width * 0.032)
                            Text("Contact")
                                .font(.system(size: g.size.width * 0.032))
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                    }
                }
                VStack {
                    Text("Species")
                        .font(.system(size: g.size.width * 0.032, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 50)
                        .padding(.top, 20)
                    if clicked[0] {
                        HStack {
                            Button(action: {clicked = [true, false, false]}) {
                                HStack {
                                    Image("cat")
                                    Text("Cat")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .background(Color("Logo-Pink"))
                            .cornerRadius(10)
                            Button(action: {clicked = [false, true, false]}) {
                                HStack {
                                    Image("pet")
                                    Text("Dog")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                            Button(action: {clicked = [false, false, true]}) {
                                HStack {
                                    Image("rabbit")
                                    Text("Other")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                        }
                    } else if clicked[1] {
                        HStack {
                            Button(action: {clicked = [true, false, false]}) {
                                HStack {
                                    Image("cat")
                                    Text("Cat")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                            Button(action: {clicked = [false, true, false]}) {
                                HStack {
                                    Image("pet")
                                    Text("Dog")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .background(Color("Logo-Pink"))
                            .cornerRadius(10)
                            Button(action: {clicked = [false, false, true]}) {
                                HStack {
                                    Image("rabbit")
                                    Text("Other")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                        }
                    } else {
                        HStack {
                            Button(action: {clicked = [true, false, false]}) {
                                HStack {
                                    Image("cat")
                                    Text("Cat")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                            Button(action: {clicked = [false, true, false]}) {
                                HStack {
                                    Image("pet")
                                    Text("Dog")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                            Button(action: {clicked = [false, false, true]}) {
                                HStack {
                                    Image("rabbit")
                                    Text("Other")
                                }
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .background(Color("Logo-Pink"))
                            .cornerRadius(10)
                        }
                    }

                }
                VStack {
                    Text("Pet's name")
                        .font(.system(size: g.size.width * 0.032, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 50)
                        .padding(.top, 20)
                    TextField("Enter your pet's name...", text: $title)
                        .padding(.leading, 50)
                        .padding(.trailing, 50)
                        .textFieldStyle(.roundedBorder)
                }
                Text("When did you lost your pet?")
                    .font(.system(size: g.size.width * 0.032, weight: .semibold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 50)
                    .padding(.top, 20)
                HStack {
                    Image(systemName: "calendar")
                        .padding(.leading, 50)
                    DatePicker("", selection: $selectedDate, in: Date()...)
                        .padding(.trailing, 60)
                }
                VStack {
                    Text("Where did you lost your pet?")
                        .font(.system(size: g.size.width * 0.032, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 50)
                        .padding(.top, 20)
                    HStack {
                        Image(systemName: "location")
                            .padding(.leading, 50)

                    }
                    Spacer()
                    NavigationLink(destination: NewReportView2(mapModel: mapModel, loginModel: loginModel)) {
                        Text("Next")
                            .navigationBarBackButtonHidden(true)
                            .navigationBarItems(leading: btnBack)
                    }
                }
            }
        }

    }

}

struct NewReportView2: View {

    var mapModel: MapViewModel
    var loginModel: LoginViewModel

    @State private var navigateTo: AnyView?
    @State private var description: String = ""
    @State private var title: String = ""
    @State private var isActive = false
    @State private var coordinates = CLLocationCoordinate2D(latitude: 37.333747, longitude: -122.011448)
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isImagePickerDisplay = false

    @State private var isFemale = false
    @State private var isSpay = false
    @State var clicked_gender = [true, false]
    @State var clicked_spay = [true, false]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var btnBack : some View { Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                    Image("vector") // set image here
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                    }
                }
            }

    var body: some View {
        GeometryReader { g in
            VStack {
                Group {
                    Text("Sorry to hear about that")
                        .font(.system(size: g.size.width * 0.05, weight: .bold, design: .default))
                    Text("")
                    Text("We are here to help you find your pet!")
                        .font(.system(size: g.size.width * 0.032))
                }
                Group {
                    ZStack {
                        VStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 220, height: 2)
                            Text("d")
                                .font(.system(size: 9, design: .default))
                                .opacity(0)
                        }
                        HStack {
                            Spacer()
                            VStack {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2)
                                    .background(Circle().foregroundColor(Color("Logo-Pink")))
                                    .frame(width: g.size.width * 0.032, height: g.size.width * 0.032)
                                Text("Basic Info")
                                    .font(.system(size: g.size.width * 0.032))
                                    .foregroundColor(Color("Logo-Pink"))
                            }
                            Spacer()
                            VStack {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2)
                                    .background(Circle().foregroundColor(Color("Logo-Pink")))
                                    .frame(width: g.size.width * 0.032, height: g.size.width * 0.032)
                                Text("Pet Info")
                                    .font(.system(size: g.size.width * 0.032))
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                            VStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: g.size.width * 0.032, height: g.size.width * 0.032)
                                Text("Contact")
                                    .font(.system(size: g.size.width * 0.032))
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                        }
                    }
                }
                Group {
                    Text("Pets Pictures")
                        .font(.system(size: g.size.width * 0.032, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 50)
                        .padding(.top, 20)
                    HStack {
                        Image("tiff").resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .clipped()
                            .frame(width: 96, height: 96)
                            .cornerRadius(10)
                            .offset(x:50)
                        Button(action: {
                            self.sourceType = .photoLibrary
                            self.isImagePickerDisplay.toggle()
                        }, label: {
                            Image("addButton").resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .clipped()
                                .frame(width: 96, height: 96)
                                .cornerRadius(10)
                                .offset(x:50)
                        })
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                Group {
                    Text("Gender")
                        .font(.system(size: g.size.width * 0.032, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 50)
                        .padding(.top, 20)
                    if clicked_gender[0] {
                        HStack {
                            Button(action: {clicked_gender = [true, false]}) {
                                Text("Female")
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .background(Color("Logo-Pink"))
                            .cornerRadius(10)
                            Button(action: {clicked_gender = [false, true]}) {
                                Text("Male")
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                        }
                    } else if clicked_gender[1] {
                        HStack {
                            Button(action: {clicked_gender = [true, false]}) {
                                Text("Female")
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                            Button(action: {clicked_gender = [false, true]}) {
                                Text("Male")
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .background(Color("Logo-Pink"))
                            .cornerRadius(10)
                        }
                    }
                }
                Group {
                    Text("Spay/Neuter?")
                        .font(.system(size: g.size.width * 0.032, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 50)
                        .padding(.top, 20)
                    if clicked_spay[0] {
                        HStack {
                            Button(action: {clicked_spay = [true, false]}) {
                                Text("Yes")
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .background(Color("Logo-Pink"))
                            .cornerRadius(10)
                            Button(action: {clicked_spay = [false, true]}) {
                                Text("No")
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                        }
                    } else if clicked_spay[1] {
                        HStack {
                            Button(action: {clicked_spay = [true, false]}) {
                                Text("Yes")
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .cornerRadius(10)
                            Button(action: {clicked_spay = [false, true]}) {
                                Text("No")
                            }
                            .foregroundColor(Color.black)
                            .buttonStyle(.bordered)
                            .background(Color("Logo-Pink"))
                            .cornerRadius(10)
                        }
                    }
                }
            
                NavigationLink(destination: NewReportView3(mapModel: mapModel, loginModel: loginModel)) {
                    Text("Next")
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: btnBack)
                }
            }
        }
    }
}


struct NewReportView3: View {
    var mapModel: MapViewModel
    var loginModel: LoginViewModel
    
    @State private var navigateTo: AnyView?
    @State private var selectedImage = UIImage(named: "cat-portrait")
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var isActive = true
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isImagePickerDisplay = false
    @State private var tagInput: String = ""
    @State private var reward = 50.0
    @State private var isEditing = false
    @State private var DM = false
    @State private var noReward = false
    @State private var petdescription: String = ""
    @State var clicked_size = [true, false, false]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var btnBack : some View { Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                    Image("vector") // set image here
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                    }
                }
            }
    
    var body: some View {
        VStack {
            VStack {
                Text("Sorry to hear about that")
                    .font(.system(size: 18, weight: .bold, design: .default))
                Text("")
                Text("We are here to help you find your pet!")
                    .font(.system(size: 14, design: .default))
            }
            
            ZStack {
                VStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 220, height: 2)
                    Text("d")
                        .font(.system(size: 9, design: .default))
                        .opacity(0)
                }
                HStack {
                    Spacer()
                    VStack {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                            .background(Circle().foregroundColor(Color("Logo-Pink")))
                            .frame(width: 13, height: 13)
                        Text("Basic Info")
                            .font(.system(size: 9, design: .default))
                            .foregroundColor(Color("Logo-Pink"))
                    }
                    Spacer()
                    VStack {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                            .background(Circle().foregroundColor(Color("Logo-Pink")))
                            .frame(width: 13, height: 13)
                        Text("Pet Info")
                            .font(.system(size: 9, design: .default))
                            .foregroundColor(Color("Logo-Pink"))
                    }
                    Spacer()
                    VStack {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                            .background(Circle().foregroundColor(Color("Logo-Pink")))
                            .frame(width: 13, height: 13)
                        Text("Contact")
                            .font(.system(size: 9, design: .default))
                            .foregroundColor(Color("Logo-Pink"))
                    }
                    Spacer()
                }
            }
            
            Group {
                Text("Size")
                    .frame(maxWidth: .infinity, alignment: .leading).padding()
                if clicked_size[0] {
                    HStack {
                        Button(action: {clicked_size = [true, false, false]}) {
                            Text("Small")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .background(Color("Logo-Pink"))
                        .cornerRadius(10)
                        Button(action: {clicked_size = [false, true, false]}) {
                            Text("Medium")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .cornerRadius(10)
                        Button(action: {clicked_size = [false, false, true]}) {
                            Text("Large")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .cornerRadius(10)
                    }
                } else if clicked_size[1] {
                    HStack {
                        Button(action: {clicked_size = [true, false, false]}) {
                            Text("Small")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .cornerRadius(10)
                        Button(action: {clicked_size = [false, true, false]}) {
                            Text("Medium")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .background(Color("Logo-Pink"))
                        .cornerRadius(10)
                        Button(action: {clicked_size = [false, false, true]}) {
                            Text("Large")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .cornerRadius(10)
                    }
                } else {
                    HStack {
                        Button(action: {clicked_size = [true, false, false]}) {
                            Text("Small")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .cornerRadius(10)
                        Button(action: {clicked_size = [false, true, false]}) {
                            Text("Medium")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .cornerRadius(10)
                        Button(action: {clicked_size = [false, false, true]}) {
                            Text("Large")
                        }
                        .foregroundColor(Color.black)
                        .buttonStyle(.bordered)
                        .background(Color("Logo-Pink"))
                        .cornerRadius(10)
                    }
                }
                
            }
            
            Group {
                Text("Pet Description").frame(maxWidth: .infinity, alignment: .leading).padding()
                TextField("Weight / Personality / Appearance", text: $petdescription).textFieldStyle(.roundedBorder).padding().padding(.top, -20)
            }
            
            Section(header: Text("Phone number")
                .frame(maxWidth: .infinity, alignment: .leading).padding()) {
                    TextField("enter: ", text: $amount).textFieldStyle(.roundedBorder).padding().padding(.top, -20)
                }
            Text("or");
            Button(action: {
                self.DM = !self.DM
                }) {

                Text("DM me via app")
                    .font(.system(size: 15))
                }
                .frame(width: 140, height: 15, alignment: .center)
                .padding(10)
                .background(DM ? Color("Logo-Pink") : Color.gray)
              
            .foregroundColor(Color.black)
            .buttonStyle(.bordered)
            .cornerRadius(10)
            
                   
            /*Section() {
                TextField("Enter amount...", text: $amount, onEditingChanged: { (changed) in
                    print("description onEditingChanged - \(changed)")
                })
            }*/
            
            Section(header: Text("Reward Amount $ (Optional)")
                .frame(maxWidth: .infinity, alignment: .leading).padding()) {
                    VStack {
                        Slider(
                            value: $reward,
                            in: 0...1000,
                            onEditingChanged: { editing in
                                isEditing = editing
                            }
                        )
                        Text("\(Int(reward))")
                            .foregroundColor(isEditing ? .red : .red)
                    }
                }
            
            Spacer()
            NavigationLink(destination: NewReportView4(mapModel: mapModel, loginModel: loginModel)) {
                Text("Post").foregroundColor(Color("Logo-Pink"))
                    .navigationBarBackButtonHidden(true)
                            .navigationBarItems(leading: btnBack)
                /*.padding().overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Logo-Pink"), lineWidth: 4))*/
                    
                
            }
        }
    }
}

struct NewReportView4: View {
    var mapModel: MapViewModel
    var loginModel: LoginViewModel

    
    var body: some View {
        Form {
                Section(header: Text("More")) {
                }
                }
                
            
    }

}



struct NewReportView: View {
    var mapModel: MapViewModel
    var loginModel: LoginViewModel

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage = UIImage(named: "cat-portrait")
    @State private var isImagePickerDisplay = false
    @State private var tagInput: String = ""
    private let tags: [String] = ["Dogs", "Cats", "Adoption"]
    @State private var showingPicker = false
    
    @State private var coordinates = CLLocationCoordinate2D(latitude: 37.333747, longitude: -122.011448)
    @State private var showSheet = false
    @State private var radius: Int = 10
    
    
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
            
            Section(header: Text("location")) {
                Text("Latitude: " + coordinates.latitude.description).foregroundColor(.gray)
                Text("Longitude: " + coordinates.longitude.description).foregroundColor(.gray)
                Text("Radius: " + String(radius)).foregroundColor(.gray)
                Picker("Radius", selection: $radius) {
                    ForEach(1...100, id: \.self) { radius in
                        Text("\(radius)")
                    }
                }
                Button("Search Location") {
                    showingPicker = true
                }
                Button("Select On Map") {
                    self.showSheet.toggle()
                }
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
            Button(action: { addLocation(username: loginModel.getEmail(), title: title, description: description, image: selectedImage!, tags: tagInput, coordinates: coordinates, radius: radius)}, label: {Text("Publish").foregroundColor(Color("Logo-Pink")).font(.system(size: 20));
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("Logo-Pink")).sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
        }.navigationTitle("Report Lost Pet")
        .mapItemPicker(isPresented: $showingPicker) { item in
            if let name = item?.name {
                coordinates = item!.placemark.coordinate
                print(coordinates.latitude)
                print("Selected \(name)")
            }
        }
        .sheet(isPresented: $showSheet) {
                NavigationView {
                    
                    // Just put the view into a sheet or navigation link
                    LocationPicker(instructions: "Tap somewhere to select your coordinates", coordinates: $coordinates)
                        
                    // You can assign it some NavigationView modifiers
                        .navigationTitle("Location Picker")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(leading: Button(action: {
                            self.showSheet.toggle()
                        }, label: {
                            Text("Close").foregroundColor(.red)
                        }))
                }
            }
    }
    
    func addLocation(username: String, title: String, description: String, image: UIImage, tags: String, coordinates: CLLocationCoordinate2D, radius: Int) {
        print(coordinates)
        print(radius)
        mapModel.addLocation(username: username, title: title, description: description, image: image, tags: tags, coordinates: coordinates, radius: radius)
    }
}

/**
  DetailedPostView defines a View for adding new posts.
*/
struct DetailedPostView: View {
    var post: Content
    var images = ["image1", "image2", "image3"]
    
    let logoPink = UIColor(red: 231/255, green: 84/255, blue: 128/255, alpha: 1)
    
    @State var liked = false

    
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = logoPink
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }

    var body: some View {
       
            VStack {
                HStack {
                    Image("denero")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: 30.0, height: 30.0)
                    Text(post.userName)
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundColor(Color("Logo-Pink"))
                        .padding()
                        .font(.system(size: 25))
                }
                
                GeometryReader { proxy in
                    TabView {
                        ForEach(self.images, id: \.self) { imageName in
                        Image(uiImage: post.image.imageFromBase64!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .onAppear {
                        setupAppearance()
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        liked = !liked
                    }) {
                        if liked {Image(systemName: "heart.fill").font(.system(size: 25)).foregroundColor(Color("Logo-Pink"))}
                        else {Image(systemName: "heart").font(.system(size: 25)).foregroundColor(Color("Logo-Pink"))}
                    }
                    Image(systemName: "message")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                }
                
                //                Text("Title: " + post.title)
                //            Text("By: " + post.userName)
                //                Text("Posted on: " + convertToDate(timeStamp: post.timeStamp))
                Text("Description: " + post.description)
                //                Text(post.timeStamp)
                //                Image(uiImage: post.image)
                //                    .resizable()
                //                    .aspectRatio(contentMode: .fit)
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
        NewPostView(postModel: PostViewModel(), loginModel: LoginViewModel(), userModel: UserViewModel())
        NewReportView1(mapModel: MapViewModel(), loginModel: LoginViewModel())
        NewReportView2(mapModel: MapViewModel(), loginModel: LoginViewModel())
        NewReportView3(mapModel: MapViewModel(), loginModel: LoginViewModel())
        NewReportView4(mapModel: MapViewModel(), loginModel: LoginViewModel())
    }
}
