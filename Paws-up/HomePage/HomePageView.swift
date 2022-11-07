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
            Text(post.title).lineLimit(1).foregroundColor(.black)
            HStack {
                Text(post.userName).frame(width: (UIScreen.main.bounds.size.width / 2) - 80).lineLimit(1).foregroundColor(.black)
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
                    }) {
                        if liked {Image(systemName: "heart.fill").foregroundColor(Color("Logo-Pink"))}
                        else {Image(systemName: "heart").foregroundColor(Color("Logo-Pink"))}
                        
                    }
                    Text(String(likeList.count)).foregroundColor(Color("Logo-Pink"))
                }.frame(width: 50)
            }
        }.frame(width: (UIScreen.main.bounds.size.width / 2) - 30)
    }
}

struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        VStack {
            Text("Searching for \(searchText)")
                .searchable(text: $searchText)
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
    var mapModel: MapViewModel
    
    @State private var navigateTo: AnyView?
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(
                        destination:
                            SearchView()) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color("Logo-Pink"))
                                    .padding()
                                    .font(.system(size: 25))
                      }
                    Spacer()
                    Menu {
                        Button(action: {
                            navigateTo = AnyView(NewPostView(postModel: postModel, loginModel: loginModel))
                            isActive = true
                        }, label: {
//                            NavigationLink(destination: NewPostView(postModel: postModel, loginModel: loginModel)) {
                                Text("New Post")
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(Color("Logo-Pink"))
//                            }
                        })
                        Button(role: .destructive) {
                            navigateTo = AnyView(NewReportView(mapModel: mapModel, loginModel: loginModel))
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
    
    //@Binding var activeLabels: [String]
    
    var body: some View {
        Spacer()
        HStack{TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            PostView(loginModel: loginModel, postModel: postModel, profileViewModel: profileViewModel, mapModel: mapModel).tabItem {
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
            ProfileView(profileViewModel: profileViewModel, profile: profileViewModel.profile, loginModel: loginModel).tabItem {
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

    var body: some View {
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
                        Image("image1")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .clipped()
                        Image("image2")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .clipped()
                        Image("image3")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .clipped()
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
        VStack {
            Section(){
                TextField("Add Title...", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                TextField("Content", text: $description)
                    .fixedSize(horizontal: false, vertical: false)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
            }
            
            HStack {
                LazyVGrid(columns: [GridItem(spacing: -5), GridItem(spacing: -5), GridItem(spacing: 5)],spacing: 20) {
                    Image("image1")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipped()
                    Image("image2")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipped()
                    Image("image3")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipped()
                }
            }.padding(.horizontal, 20)
            
            HStack {
                LazyVGrid(columns: [GridItem(spacing: -5), GridItem(spacing: -5), GridItem(spacing: 5)],spacing: 20) {
                    Image("image5")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipped()
                    Image("image6")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipped()
                    Menu {
                        Button("Camera") {
                            self.sourceType = .camera
                            self.isImagePickerDisplay.toggle()
                        }
                        Button("Photo") {
                            self.sourceType = .photoLibrary
                            self.isImagePickerDisplay.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color("Logo-Pink"))
                            .padding()
                            .font(.system(size: 25))
                    }
                }
                
            }.padding(.horizontal, 20)
            
            TextField("# Add Tags", text: $tagInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .onTapGesture {
                    Picker("Selected Tag", selection: $tagInput) {
                        ForEach(tags, id: \.self) {
                            Text($0).tag(tags)
                        }
                    }
                }
            TextField("Add Location", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                
            
            Button(action: { addPost(username: loginModel.getEmail(), title: title, description: description, image: selectedImage!, tags: tagInput)}, label: {Text("Publish Post").foregroundColor(Color("Logo-Pink")).font(.system(size: 20));
            }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("Logo-Pink")).sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
        }.navigationBarTitle(Text("Add Post"), displayMode: .inline)
            .navigationBarBackButtonHidden(false)
    }
    
    func addPost(username: String, title: String, description: String, image: UIImage, tags: String) {
        postModel.addPost(userName: username, title: title, description: description, image: image, tags: tags)
    }
}

/**
  NewReportView defines a View for adding new reports.
*/
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
        
    @State var liked = false
    
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color("Logo-Pink"))
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
        NewPostView(postModel: PostViewModel(), loginModel: LoginViewModel())
    }
}
