//
//  ContentView.swift
//  Paws-up
//
//  Created by Hanning Xu on 2/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            UserButtonView()
            Spacer()
            SearchBar(text: .constant(""))
            Spacer()
            NewPostButtonView()
        }
        
        CollectCardView()
        Spacer()
        BottomButtonView()
    }
}


struct CollectCardView: View {
    var imagePaths = ["cat-portrait", "dog-portrait", "dog-landscape", "cat-landscape", "parrot", "red-panda"] // Array of images paths
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(imagePaths, id: \.self, content: { name in
                        NavigationLink(
                            destination: ImageView(imageName: name)) {
                                CardView(imageName: name)
                          }
                    }
                    )
                }
            }.padding(5)
        }
    }
}


struct CardView: View {
    var imageName: String
    
    @State
    var likes: Int = 0
    
    @State
    var liked: Bool = false
    
    var heartEmpty: some View {
        Button(action: {
            if (!liked) {
                likes += 1
            } else {
                likes -= 1
            }
            liked = !liked
        }, label: {
            if (liked) {
                Image(systemName: "heart.fill")
                    .foregroundColor(Color("logo-pink"))
            } else {
                Image(systemName: "heart")
                    .foregroundColor(Color("logo-pink"))
            }
        })
    }
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipped()
            HStack{
                Spacer()
                Text(imageName).foregroundColor(.black)
                Spacer()
                heartEmpty
                Text(String(likes))
                    .foregroundColor(Color("logo-pink"))
            }
        }
    }
}

struct BottomButtonView: View {
    @State var ignore = 0 //"spaceholder" variable
    
    var body: some View {
        HStack {
            Spacer()
            button1
            Spacer()
            button2
            Spacer()
            button3
            Spacer()
            button4
            Spacer()
        }
    }
    
    var button1: some View {
        Button(action: {
           ignore += 1
        }, label: {
            Image(systemName: "pawprint.fill").foregroundColor(Color("logo-pink")).font(.system(size: 30))
        })
    }

    var button2: some View {
        Button(action: {
           ignore += 1
        }, label: {
            Image(systemName: "pawprint").foregroundColor(Color("logo-pink")).font(.system(size: 30))
        })
    }
    
    var button3: some View {
        Button(action: {
           ignore += 1
        }, label: {
            Image(systemName: "pawprint.fill").foregroundColor(Color("logo-pink")).font(.system(size: 30))
        })
    }

    var button4: some View {
        Button(action: {
           ignore += 1
        }, label: {
            Image(systemName: "pawprint").foregroundColor(Color("logo-pink")).font(.system(size: 30))
        })
    }
}

struct UserButtonView: View {
    
    var body: some View {
        userIcon.frame(alignment: Alignment.topLeading)
        Spacer()
    }
    
    @State var userName = "user"
    
    var userIcon: some View {
        Button(action: {
            userName //TODO: tap to show user profile
        }, label: {
            Image(systemName: "person.circle").foregroundColor(Color("logo-pink")).padding().font(.system(size: 30))
        })
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
            Image(systemName: "square.and.pencil").foregroundColor(Color("logo-pink")).padding().font(.system(size: 30))
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
                .animation(.default)
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
        ContentView()
    }
}
