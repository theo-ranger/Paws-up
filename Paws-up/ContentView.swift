import SwiftUI

struct ContentView: View {
    @ObservedObject var loginModel = LoginViewModel()
    
    @ObservedObject var postModel = PostViewModel()
    
    @ObservedObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            if (loginModel.isLoggedIn) {
                HomePageView(loginModel: loginModel, postModel: postModel, profileViewModel: profileViewModel)
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
