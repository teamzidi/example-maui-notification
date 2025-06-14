import SwiftUI

@main
struct MiserApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView() // Assuming ContentView is the main view
        }
    }
}
