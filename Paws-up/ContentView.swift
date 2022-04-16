//
//  ContentView.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: PostViewModel
    
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        Spacer()
        HStack{TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            NavigationView {
                VStack {
                    HStack {
                        Button(action: { }, label: {
                            NavigationLink(destination: ProfileView(viewModel: profileViewModel, profile: profileViewModel.profile)) {
                                Image(systemName: "person.circle").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
                            }
                        }).frame(alignment: Alignment.topTrailing)
                        Spacer()
                        SearchBar(text: .constant(""))
                        Spacer()
                        NewPostButton()
                    }
                    Spacer()
                    ScrollView {
                        LazyVGrid(columns: [GridItem(spacing: 30), GridItem(spacing: 30)],spacing: 10) {
                            ForEach(viewModel.posts) { post in
                                NavigationLink(
                                    destination: ImageView(imageName: post.content.imageAddress).frame(width: 100, height: 200)) {
                                        CardView(viewModel: viewModel, post: post)
                                  }
                            }
                        }
                    }.padding(5)
                        .navigationBarHidden(true)
                        .animation(.default, value: true)
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
    }}


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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                CircleImage(image: Image("denero"))
                    .offset(y: -130)
                    .padding(.bottom, -130)
                Text(profile.userName)
                    .bold()
                    .font(.title)
                Text("Birthyear: " + profile.birthYear)
                Text("Favorite Animal: " + profile.favoriteAnimal)
                Text("Email: " + profile.email)
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
    var body: some View {
        penIcon.frame(alignment: Alignment.topTrailing)
        Spacer()
    }
    
    var penIcon: some View {
        Button(action: { }, label: {
            NavigationLink(destination: NewPostView()) {
                Image(systemName: "square.and.pencil").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
            }
        })
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
        let app = PostViewModel()
        
        let profile = ProfileViewModel()
        
        Group {
            ContentView(viewModel: app, profileViewModel: profile)
            NewPostView()
        }
    }
}
