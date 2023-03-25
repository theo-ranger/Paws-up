//
//  StarterView.swift
//  Paws-up
//
//  Created by Hanning Xu and Jiayu Shi on 2/12/22.
//


import SwiftUI

struct StarterView: View {
    @ObservedObject var loginModel = LoginViewModel()
    @ObservedObject var postModel = PostViewModel()
    @ObservedObject var profileViewModel = ProfileViewModel()
    @ObservedObject var userViewModel = UserViewModel()
    
    var mapModel = MapViewModel()
    
    var body: some View {
        VStack {
            if (loginModel.isLoggedIn) {
                //TestView(postModel: postModel, loginModel: loginModel)
                HomePageView(loginModel: loginModel, postModel: postModel, profileViewModel: profileViewModel, mapModel: mapModel, userModel: userViewModel)
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
