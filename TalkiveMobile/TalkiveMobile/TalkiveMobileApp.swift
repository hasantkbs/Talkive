import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TalkiveMobileApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if authViewModel.isAuthenticated {
                        ChatScreen()
                    } else {
                        SplashScreen()
                    }
                }
            }
            .environmentObject(authViewModel)
            .environmentObject(settingsViewModel)
            .background(settingsViewModel.selectedTheme.backgroundColor)
            .onChange(of: settingsViewModel.selectedTheme) { _ in
                applyTheme(settingsViewModel.selectedTheme)
            }
            .onAppear {
                applyTheme(settingsViewModel.selectedTheme)
            }
        }
    }

    private func applyTheme(_ theme: AppTheme) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        windowScene.windows.first?.overrideUserInterfaceStyle = theme.colorScheme.toUIUserInterfaceStyle()

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(theme.navigationBarColor)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension Optional where Wrapped == ColorScheme {
    func toUIUserInterfaceStyle() -> UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return .unspecified
        }
    }
}
