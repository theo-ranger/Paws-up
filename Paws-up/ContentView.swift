//
//  ContentView.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: PostViewModel
    
    var body: some View {
        Spacer()
        HStack{TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            VStack {
                HStack {
                    UserButtonView()
                    Spacer()
                    SearchBar(text: .constant(""))
                    Spacer()
                    NewPostButtonView()
                }
                Spacer()
                NavigationView {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(), GridItem()]) {
                            ForEach(viewModel.posts) { post in
                                NavigationLink(
                                    destination: ImageView(imageName: post.content.imageAddress)) {
                                        CardView(viewModel: viewModel, post: post)
                                  }
                            }
                        }
                    }.padding(5)
                        .navigationBarHidden(true)
                        .animation(.default, value: true)
            }
            }.tabItem {
                Image(systemName: "allergens")
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

struct UserButtonView: View {
    
    var body: some View {
        userIcon.frame(alignment: Alignment.topLeading)
        Spacer()
    }
    
    @State var userName = "user"
    
    var userIcon: some View {
        NavigationLink(destination: ProfileView()) {
            Button(action: {
            }) {
                Image(systemName: "person.circle").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
            }
        }
    }
    
}

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("profile.username")
                    .bold()
                    .font(.title)
                Text("Notifications: ")
                Text("Seasonal Photos: ")
                Text("Goal Date: ")
            }
        }
    }
}

struct NewPostButtonView: View {
    
    var body: some View {
        penIcon.frame(alignment: Alignment.topTrailing)
        Spacer()
        
    }
    
    @State var post = "text"
    
    var penIcon: some View {
        Button(action: {
            post //TODO: tap to write a new post
        }, label: {
            Image(systemName: "square.and.pencil").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
        })
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
        
        ContentView(viewModel: app)
    }
}
