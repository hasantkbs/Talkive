import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var settingsViewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(settingsViewModel.currentUserEmail ?? "N/A")
                        .foregroundColor(.gray)
                }
                
                Button("Logout") {
                    Task {
                        await authViewModel.logout()
                        dismiss()
                    }
                }
                .foregroundColor(.red)
            }
            
            Section(header: Text("Change Password")) {
                SecureField("New Password", text: $settingsViewModel.newPassword)
                SecureField("Confirm New Password", text: $settingsViewModel.confirmPassword)
                
                if settingsViewModel.isLoadingPasswordChange {
                    ProgressView()
                }
                
                if let error = settingsViewModel.passwordChangeError {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button("Change Password") {
                    Task {
                        await settingsViewModel.changePassword()
                    }
                }
                .disabled(settingsViewModel.newPassword.isEmpty || settingsViewModel.confirmPassword.isEmpty || settingsViewModel.isLoadingPasswordChange)
            }
            
            Section(header: Text("Appearance")) {
                Picker("App Theme", selection: $settingsViewModel.selectedTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.description).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: settingsViewModel.selectedTheme) { _ in
                    settingsViewModel.saveTheme()
                }

                Picker("Practice Language", selection: $settingsViewModel.selectedLanguage) {
                    Text("English").tag("en")
                    Text("Turkish").tag("tr")
                    Text("Spanish").tag("es")
                }
                .pickerStyle(.menu)
                .onChange(of: settingsViewModel.selectedLanguage) { _ in
                    settingsViewModel.saveLanguage()
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Password Changed", isPresented: $settingsViewModel.showPasswordChangeSuccess) {
            Button("OK") { }
        } message: {
            Text("Your password has been successfully updated.")
        }
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(AuthViewModel())
}
