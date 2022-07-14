//
//  ContentView.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//


import SwiftUI

struct ContentView: View {
    @ObservedObject var loginModel = LoginViewModel()
    
    @ObservedObject var postModel = PostViewModel()
    
    @ObservedObject var profileViewModel = ProfileViewModel()
    
    var rescueModel = RescueViewModel()
    
    var body: some View {
        VStack {
            if (loginModel.isLoggedIn) {
                TestView(postModel: postModel)
                //HomePageView(loginModel: loginModel, postModel: postModel, profileViewModel: profileViewModel, rescueModel: rescueModel)
            } else {
                LoginView(loginModel: loginModel)
            }
        }
        .alert("Error", isPresented: $loginModel.hasError) {
        } message: {
            Text(loginModel.errorMessage)
        }
        .padding()
    }
}
