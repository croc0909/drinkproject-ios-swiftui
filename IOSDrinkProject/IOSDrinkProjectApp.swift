import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        print("FirebaseApp init")
        return true
    }
}

@main
struct IOSDrinkProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
        private var delegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
