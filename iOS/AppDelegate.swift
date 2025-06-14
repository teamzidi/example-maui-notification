import UIKit
import UserNotifications // Required for push notifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UNUserNotificationCenter.current().delegate = self

        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            if granted {
                print("Notification permission granted.")
                // Register for remote notifications on the main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied.")
            }
        }
        return true
    }

    // Successfully registered for remote notifications and received device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        // Here you would typically send the token to your backend server
    }

    // Failed to register for remote notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Handle notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo
        print("Notification received in foreground: \(userInfo)")

        // Show alert, sound, and badge while app is in foreground
        // For iOS 14 and later, .list and .banner are available.
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .list, .badge]) // Added .badge as well
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    // Handle user's response to a delivered notification (e.g., tapping it)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped (or other action): \(userInfo)")

        // Example: You could extract data from userInfo to navigate to a specific part of the app
        // if let customData = userInfo["custom_key"] as? String {
        //     print("Custom data received: \(customData)")
        // }

        // Make sure to call the completion handler when you're done processing the response
        completionHandler()
    }
}
