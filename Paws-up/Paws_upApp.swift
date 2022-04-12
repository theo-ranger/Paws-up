//
//  Paws_upApp.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//

import SwiftUI

@main
struct Paws_upApp: App {
    let app = PostViewModel()
    
    let profile = ProfileViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: app, profileViewModel: profile)
        }
    }
}
