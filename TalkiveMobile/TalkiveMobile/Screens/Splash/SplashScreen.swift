import SwiftUI

struct SplashScreen: View {
    @StateObject private var viewModel = SplashViewModel()
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Color(viewModel.connectionFailed ? .red : .blue).ignoresSafeArea()
            
            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 150, height: 150)
                    Image("AppIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                
                Text("Talkive")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text(viewModel.connectionStatus)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                if viewModel.connectionFailed {
                    Button {
                        Task { await viewModel.checkAPIConnection() }
                    } label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                } else if !isActive {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top, 30)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.checkAPIConnection()
                if !viewModel.connectionFailed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isActive = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            AuthScreen()
        }
    }
}

#Preview {
    SplashScreen()
}