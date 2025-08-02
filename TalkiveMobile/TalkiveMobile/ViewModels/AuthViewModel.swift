import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService.shared
    private let userDefaults = UserDefaults.standard
    private let authTokenKey = "authToken"
    
    init() {
        // Firebase kimlik doğrulama durumundaki değişiklikleri dinle
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isAuthenticated = (user != nil)
                // Eğer kullanıcı yoksa ve token varsa temizle (eski simülasyon tokenları için)
                if user == nil && self.userDefaults.string(forKey: self.authTokenKey) != nil {
                    self.userDefaults.removeObject(forKey: self.authTokenKey)
                }
            }
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            // Firebase otomatik olarak isAuthenticated'ı güncelleyecek
            print("User logged in: \(result.user.uid)")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // Firebase otomatik olarak isAuthenticated'ı güncelleyecek
            print("User signed up: \(result.user.uid)")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func logout() async {
        do {
            try Auth.auth().signOut()
        await MainActor.run {
            self.isAuthenticated = false
        }
        await MainActor.run {
            self.isAuthenticated = false
        }
        await MainActor.run {
            self.isAuthenticated = false
        }
            // Firebase otomatik olarak isAuthenticated'ı güncelleyecek
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Test ve hata ayıklama için oturum durumunu sıfırlama
    func reset() async {
        await logout() // Firebase oturumunu kapat
        userDefaults.removeObject(forKey: authTokenKey) // Eski simülasyon tokenını temizle
        isAuthenticated = false
        errorMessage = nil
        isLoading = false
    }
}