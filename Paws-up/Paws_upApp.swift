//
//  Paws_upApp.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import SwiftUI
import Firebase

@main
struct Paws_upApp: App {
    let app = PostViewModel()

    let profile = ProfileViewModel()
    
    init() {
        print("pawsup app called")
        if FirebaseApp.app() == nil { FirebaseApp.configure() }

    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(postModel: app, profileViewModel: profile)
        }
    }
}
