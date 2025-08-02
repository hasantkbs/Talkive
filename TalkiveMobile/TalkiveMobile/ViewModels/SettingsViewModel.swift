import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var showPasswordChangeSuccess = false
    @Published var passwordChangeError: String? = nil
    @Published var isLoadingPasswordChange = false
    
    @Published var selectedTheme: AppTheme = .system // Varsayılan tema
    @Published var selectedLanguage: String = "en" // Varsayılan dil

    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }

    init() {
        // Kaydedilmiş temayı yükle
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme") {
            selectedTheme = AppTheme(rawValue: savedTheme) ?? .system
        }
        // Kaydedilmiş dili yükle
        if let savedLanguage = UserDefaults.standard.string(forKey: "practiceLanguage") {
            selectedLanguage = savedLanguage
        }
    }

    func changePassword() async {
        guard let user = Auth.auth().currentUser else {
            passwordChangeError = "No user logged in."
            return
        }

        guard !newPassword.isEmpty, newPassword == confirmPassword else {
            passwordChangeError = "Passwords do not match or are empty."
            return
        }

        isLoadingPasswordChange = true
        passwordChangeError = nil

        do {
            try await user.updatePassword(to: newPassword)
            showPasswordChangeSuccess = true
            newPassword = ""
            confirmPassword = ""
        } catch {
            passwordChangeError = error.localizedDescription
        }
        isLoadingPasswordChange = false
    }

    func saveTheme() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "appTheme")
    }

    func saveLanguage() {
        UserDefaults.standard.set(selectedLanguage, forKey: "practiceLanguage")
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var backgroundColor: Color? {
        switch self {
        case .system: return nil // Sistem varsayılanını kullan
        case .light: return Color.white
        case .dark: return Color(red: 0.15, green: 0.15, blue: 0.15) // Daha yumuşak bir koyu gri
        }
    }
    
    var inputBackgroundColor: Color {
        switch self {
        case .system: return Color(.systemBackground) // Sistem varsayılanını kullan
        case .light: return Color.white
        case .dark: return Color(red: 0.2, green: 0.2, blue: 0.2) // Koyu tema için daha açık gri
        }
    }
    
    var navigationBarColor: Color {
        switch self {
        case .system: return Color(.systemBackground) // Sistem varsayılanını kullan
        case .light: return Color(red: 0.95, green: 0.95, blue: 0.95) // Açık tema için çok açık gri
        case .dark: return Color(red: 0.1, green: 0.1, blue: 0.1) // Koyu tema için koyu gri
        }
    }
}
