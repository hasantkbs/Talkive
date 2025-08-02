import Foundation

@MainActor
class SplashViewModel: ObservableObject {
    @Published var connectionStatus: String = "Connecting to API server..."
    @Published var connectionFailed: Bool = false
    
    func checkAPIConnection() async {
        connectionStatus = "Connecting to API server..."
        connectionFailed = false
        
        let isConnected = await APIService.shared.checkServerStatus()
        
        if isConnected {
            connectionStatus = "Connection Successful!"
            connectionFailed = false
        } else {
            connectionStatus = "Connection Failed.\nPlease make sure the API server is running."
            connectionFailed = true
        }
    }
}
