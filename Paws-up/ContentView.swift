//
//  ContentView.swift
//  Paws-up
//
//  Created by Hanning Xu on 2/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CollectCardView()
        Spacer()
        ButtonView()
    }
}


struct CollectCardView: View {
    var imagePaths = ["cat-portrait", "dog-portrait"] // Array of images paths
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(imagePaths, id: \.self, content: { name in
                    CardView(imageName: name)
                }
                )
            }
        }
    }
}


struct CardView: View {
    var imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipped()
            Text("title")
        }
    }
}

struct ButtonView: View {
    @State var ignore = 0 //"spaceholder" variable
    
    var body: some View {
        HStack {
            button1
            Spacer()
            button2
            Spacer()
            button3
            Spacer()
            button4
        }
    }
    
    var button1: some View {
        Button(action: {
           ignore += 1
        },label:{
            Image(systemName: "pawprint.fill")
        })
    }

    var button2: some View {
        Button(action: {
           ignore += 1
        },label:{
            Image(systemName: "pawprint")
        })
    }
    
    var button3: some View {
        Button(action: {
           ignore += 1
        },label:{
            Image(systemName: "pawprint.fill")
        })
    }

    var button4: some View {
        Button(action: {
           ignore += 1
        },label:{
            Image(systemName: "pawprint")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
