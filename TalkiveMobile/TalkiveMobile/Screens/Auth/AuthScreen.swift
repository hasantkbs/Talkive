import SwiftUI

struct AuthScreen: View {
    @State private var showLogin = true
    
    var body: some View {
        VStack {
            Image(systemName: "message.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Welcome to Talkive")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            Text("Your personal language learning assistant")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, 50)
            
            Picker("Auth Mode", selection: $showLogin) {
                Text("Login").tag(true)
                Text("Sign Up").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if showLogin {
                LoginScreen()
                    .transition(.slide)
            } else {
                SignUpScreen()
                    .transition(.slide)
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    AuthScreen()
        .environmentObject(AuthViewModel())
}