using Foundation;
using Firebase.CloudMessaging; // For Messaging
using Firebase.Core; // For App.Configure()
using UIKit;
using UserNotifications; // For UNUserNotificationCenter
using System; // For Environment and Console.WriteLine
using Microsoft.Maui.ApplicationModel; // For MainThread

namespace ExampleNotification;

[Register("AppDelegate")]
public class AppDelegate : MauiUIApplicationDelegate, IUNUserNotificationCenterDelegate, IMessagingDelegate
{
	protected override MauiApp CreateMauiApp() => MauiProgram.CreateMauiApp();

	public override bool FinishedLaunching(UIApplication application, NSDictionary launchOptions)
	{
		// Initialize Firebase
		try
		{
			App.Configure();
			Console.WriteLine("Firebase initialized successfully.");
		}
		catch (Exception ex)
		{
			Console.WriteLine($"Firebase initialization failed: {ex}");
		}

		// Request notification authorization
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
                        // Get the notification settings to ensure they are still valid
                        UNUserNotificationCenter.Current.GetNotificationSettings((settings) => {
                            if (settings.AuthorizationStatus == UNAuthorizationStatus.Authorized)
                            {
                                // Use MainThread.BeginInvokeOnMainThread for MAUI
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
			UNUserNotificationCenter.Current.Delegate = this;
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

		// Set the FCM messaging delegate
		Messaging.SharedInstance.Delegate = this;
        Console.WriteLine("Firebase Messaging delegate set.");

		return base.FinishedLaunching(application, launchOptions);
	}

	[Export("application:didRegisterForRemoteNotificationsWithDeviceToken:")]
	public void RegisteredForRemoteNotifications(UIApplication application, NSData deviceToken)
	{
		Messaging.SharedInstance.ApnsToken = deviceToken; // Important: Set APNS token for FCM
		Console.WriteLine($"FCM APNS token received: {deviceToken}");
		var tokenString = deviceToken.Description.Trim('<', '>').Replace(" ", "");
		Console.WriteLine($"FCM APNS token string: {tokenString}");
		// TODO: Send this token to your application server.
	}

	[Export("application:didFailToRegisterForRemoteNotificationsWithError:")]
	public void FailedToRegisterForRemoteNotifications(UIApplication application, NSError error)
	{
		Console.WriteLine($"Failed to register for remote notifications: {error.LocalizedDescription}");
		// TODO: Handle the error (e.g., log, inform user).
	}

	// Called when a remote notification is received and the app is in the background or inactive.
	[Export("application:didReceiveRemoteNotification:fetchCompletionHandler:")]
	public void DidReceiveRemoteNotification(UIApplication application, NSDictionary userInfo, Action<UIBackgroundFetchResult> completionHandler)
	{
		Console.WriteLine("Received remote notification (background/inactive): " + userInfo);

		// Pass the message to Firebase Messaging
        Messaging.SharedInstance.AppDidReceiveMessage(userInfo);

		// TODO: Process the notification data (e.g., navigate to a specific screen).
		// This is also a good place to update your app's UI if needed,
		// for example, by refreshing data based on the notification content.

		// Call the completion handler to indicate the result of the fetch operation.
		completionHandler(UIBackgroundFetchResult.NewData); // Or .NoData / .Failed
	}

	// Called when a notification is delivered to a foreground app (iOS 10+).
	[Export("userNotificationCenter:willPresentNotification:withCompletionHandler:")]
	public void WillPresentNotification(UNUserNotificationCenter center, UNNotification notification, Action<UNNotificationPresentationOptions> completionHandler)
	{
		Console.WriteLine("Received remote notification (foreground): " + notification.Request.Content.UserInfo);

        // You can process the notification here.
        // The userInfo dictionary contains the notification data.
        NSDictionary userInfo = notification.Request.Content.UserInfo;
        Messaging.SharedInstance.AppDidReceiveMessage(userInfo);


		// TODO: Customize presentation options as needed.
		// By default, show alert, sound, and badge.
		completionHandler(UNNotificationPresentationOptions.Alert | UNNotificationPresentationOptions.Sound | UNNotificationPresentationOptions.Badge);
		// If you don't want to show the notification (e.g., you want to handle it with an in-app UI):
		// completionHandler(UNNotificationPresentationOptions.None);
	}

	// Called when the user taps on a notification (iOS 10+).
	[Export("userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:")]
	public void DidReceiveNotificationResponse(UNUserNotificationCenter center, UNNotificationResponse response, Action completionHandler)
	{
		Console.WriteLine("User tapped notification: " + response.Notification.Request.Content.UserInfo);
        NSDictionary userInfo = response.Notification.Request.Content.UserInfo;

        // Pass the message to Firebase Messaging, though it might have already been handled
        // if AppDidReceiveMessage was called in DidReceiveRemoteNotification or WillPresentNotification.
        // Messaging.SharedInstance.AppDidReceiveMessage(userInfo); // Optional, depending on your flow

		// TODO: Handle the user's interaction with the notification.
		// For example, navigate to a specific screen in your app based on data in userInfo.

		completionHandler();
	}

	// Called when FCM refreshes the registration token.
	[Export("messaging:didReceiveRegistrationToken:")]
	public void DidReceiveRegistrationToken(Messaging messaging, string fcmToken)
	{
		Console.WriteLine($"Firebase registration token refreshed: {fcmToken}");
		// TODO: Notify your application server about the new or refreshed token.
		// This token is different from the APNS token. It's the FCM registration token.
		// Send this to your server to target this device for FCM messages.
	}
}
