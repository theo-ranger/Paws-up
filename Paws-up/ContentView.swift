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
    }
}

struct CollectCardView: View {
    var imagePaths = ["cat-portrait", "dog-portrait"] // Array of images paths
    
    @State var ignore = 0 //"spaceholder" variable
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem()]) {
                ForEach(imagePaths, id: \.self, content: { name in
                    CardView(imageName: name)
                }
                )
            }
        }
        Spacer()
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


struct CardView: View {
    var imageName: String
    
    var body: some View {
        ZStack {
            Image(imageName) //image
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
