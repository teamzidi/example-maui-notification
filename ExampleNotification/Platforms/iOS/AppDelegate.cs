using Foundation;
// using Firebase.CloudMessaging; // Removed, Plugin.Firebase handles this
// using Firebase.Core; // Removed, Plugin.Firebase handles this
using UIKit;
using UserNotifications; // Still needed for RequestAuthorization
using System; // For Console.WriteLine
using Microsoft.Maui.ApplicationModel; // For MainThread

namespace ExampleNotification;

[Register("AppDelegate")]
public class AppDelegate : MauiUIApplicationDelegate // Removed IUNUserNotificationCenterDelegate, IMessagingDelegate
{
	protected override MauiApp CreateMauiApp() => MauiProgram.CreateMauiApp();

	public override bool FinishedLaunching(UIApplication application, NSDictionary launchOptions)
	{
		// FirebaseApp.Configure(); // Removed, Plugin.Firebase handles initialization via MauiProgram.cs

		// Request notification authorization - This should remain the app's responsibility
		if (UIDevice.CurrentDevice.CheckSystemVersion(10, 0))
		{
			UNUserNotificationCenter.Current.RequestAuthorization(
				UNAuthorizationOptions.Alert | UNAuthorizationOptions.Badge | UNAuthorizationOptions.Sound,
				(approved, err) => {
					Console.WriteLine($"Notification authorization approved: {approved}");
					if (err != null)
					{
						Console.WriteLine($"Notification authorization error: {err.LocalizedDescription}");
					}
					if (approved)
					{
                        UNUserNotificationCenter.Current.GetNotificationSettings((settings) => {
                            if (settings.AuthorizationStatus == UNAuthorizationStatus.Authorized)
                            {
                                MainThread.BeginInvokeOnMainThread(() => {
                                    UIApplication.SharedApplication.RegisterForRemoteNotifications();
                                    Console.WriteLine("Registered for remote notifications initiated on main thread.");
                                });
                            }
                            else
                            {
                                Console.WriteLine("Notification authorization status not authorized after approval.");
                            }
                        });
					}
				});
			// UNUserNotificationCenter.Current.Delegate = this; // Removed, Plugin.Firebase handles this
		}
		else
		{
			// Fallback for iOS 9 and older
			var allNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound;
			var settings = UIUserNotificationSettings.GetSettingsForTypes(allNotificationTypes, null);
            MainThread.BeginInvokeOnMainThread(() => {
			    UIApplication.SharedApplication.RegisterUserNotificationSettings(settings);
			    UIApplication.SharedApplication.RegisterForRemoteNotifications();
                Console.WriteLine("Registered for remote notifications (legacy).");
            });
		}

		// Messaging.SharedInstance.Delegate = this; // Removed, Plugin.Firebase handles this
        // Console.WriteLine("Firebase Messaging delegate set."); // Removed

		return base.FinishedLaunching(application, launchOptions);
	}

	[Export("application:didRegisterForRemoteNotificationsWithDeviceToken:")]
	public void RegisteredForRemoteNotifications(UIApplication application, NSData deviceToken)
	{
		// Messaging.SharedInstance.ApnsToken = deviceToken; // Removed, Plugin.Firebase should handle this
		Console.WriteLine($"System didRegisterForRemoteNotificationsWithDeviceToken: {deviceToken}");
		var tokenString = deviceToken.Description.Trim('<', '>').Replace(" ", "");
		Console.WriteLine($"System APNS token string: {tokenString}");
		// Plugin.Firebase should automatically pick up this token if correctly configured.
		// If manual forwarding to Plugin.Firebase is needed, consult its documentation.
		// For example: CrossFirebaseCloudMessaging.Current.DidReceiveApnsToken(deviceToken); (This is hypothetical)
	}

	[Export("application:didFailToRegisterForRemoteNotificationsWithError:")]
	public void FailedToRegisterForRemoteNotifications(UIApplication application, NSError error)
	{
		Console.WriteLine($"System didFailToRegisterForRemoteNotificationsWithError: {error.LocalizedDescription}");
		// TODO: Handle the error (e.g., log, inform user).
	}

	// Removed DidReceiveRemoteNotification
	// Removed WillPresentNotification
	// Removed DidReceiveNotificationResponse
	// Removed DidReceiveRegistrationToken
}
