//
//  ProfileView.swift
//  Paws-up
//
//  Created by Yuhan Chen on 2/11/23.
//

import Foundation
import SwiftUI

import Foundation
import Firebase
import FirebaseStorage
import UIKit
import FirebaseFunctions

//let path = "users"
//
///**
//  PostView defines the subview for the Profile Tab.
//*/
//struct ProfileView: View {
//    var profile: Profile
//    //var loginModel: LoginViewModel
//
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 10) {
//                profile.backgroundPic
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .opacity(0.8)
//                    .overlay(
//                        profile.profilePic.clipShape(Circle())
//                            .offset(y: 80)
//                    )
//                Spacer()
//                Spacer()
//                Spacer()
//                Spacer()
//                HStack {
//                    Spacer()
//                    Text(profile.userName)
//                        .font(.system(size: 30))
//                    Spacer()
//                }
//                HStack {
//                    Spacer()
//                    VStack {
//                        Text(String(profile.followers.count)).font(.system(size: 18))
//                        Text("Followers").font(.system(size: 14))
//                    }
//                    Spacer().frame(width: 20)
//                    VStack {
//                        Text(String(profile.followees.count)).font(.system(size: 18))
//                        Text("Following").font(.system(size: 14))
//                    }
//                    Spacer()
//                }
////                Text("Email: " + loginModel.getEmail())
//                HStack {
//                    Spacer()
//                    VStack {
//                        Text("Posts").font(.system(size: 14))
//                        Rectangle().fill(Color.black).frame(width: 30, height: 1, alignment: .center).offset(y: -10)
//                    }
//                    Spacer().frame(width: 24)
//                    VStack {
//                        Text("Liked").font(.system(size: 14))
//                        Rectangle().fill(Color.gray).frame(width: 30, height: 1, alignment: .center).offset(y: -10)
//                    }
//                    Spacer()
//                }
//                VStack {
//                    HStack {
//                        Image("image1")
//                            .resizable()
//                            .aspectRatio(1.0, contentMode: .fit)
//                            .clipped()
//                        Image("image2")
//                            .resizable()
//                            .aspectRatio(1.0, contentMode: .fit)
//                            .clipped()
//                        Image("image3")
//                            .resizable()
//                            .aspectRatio(1.0, contentMode: .fit)
//                            .clipped()
//                    }
//                    HStack {
//                        Image("image4")
//                            .resizable()
//                            .aspectRatio(1.0, contentMode: .fit)
//                            .clipped()
//                        Image("image5")
//                            .resizable()
//                            .aspectRatio(1.0, contentMode: .fit)
//                            .clipped()
//                        Image("image6")
//                            .resizable()
//                            .aspectRatio(1.0, contentMode: .fit)
//                            .clipped()
//                    }
//                }
////                Button(action: {
////                    Task {
////                        await loginModel.signOut()
////                    }
////                }) {
////                    Text("Log Out")
////                }
//            }
//        }
//    }
//}
//
struct Profile: Identifiable {

    var id: String
    var profilePic: String
    var background: String
    var name: String
    var followers: [String]
    var following: [String]
    var posts: [String]


}
