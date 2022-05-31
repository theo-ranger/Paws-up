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
    
    init() {
        if FirebaseApp.app() == nil { FirebaseApp.configure() }

    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
