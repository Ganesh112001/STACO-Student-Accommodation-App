import SwiftUI
import Firebase

// Configure Firebase at app launch
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Firebase configured in AppDelegate")
    return true
  }
}

@main
struct StacoApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Create ViewModels
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var accommodationViewModel = AccommodationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Add a temporary colored background to check if views are rendering
                Color.yellow.ignoresSafeArea()
                
                ContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(accommodationViewModel)
            }
            .onAppear {
                print("Main view appeared")
                NotificationManager.shared.requestAuthorization()
                NotificationManager.shared.setupMessaging()
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var accommodationViewModel: AccommodationViewModel
    
    var body: some View {
        ZStack {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .onAppear {
                        print("MainTabView appeared")
                    }
            } else {
                LoginView()
                    .onAppear {
                        print("LoginView appeared")
                    }
            }
        }
        .onAppear {
            print("ContentView appeared - Auth state: \(authViewModel.isLoggedIn)")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("App became active, checking auth state")
            authViewModel.checkAuthState()
        }
    }
}
