using Android.App;
using Android.Content.PM;
using Android.OS;
using Android.Content; // For NotificationService
// using Firebase; // Removed as FirebaseApp.InitializeApp is no longer called here
using System;
// using Android.Gms.Common;
using Android.Util;
using AndroidX.Core.Content; // Required for ContextCompat

namespace ExampleNotification;

[Activity(Theme = "@style/Maui.SplashTheme", MainLauncher = true, LaunchMode = LaunchMode.SingleTop, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation | ConfigChanges.UiMode | ConfigChanges.ScreenLayout | ConfigChanges.SmallestScreenSize | ConfigChanges.Density)]
public class MainActivity : MauiAppCompatActivity
{
    public const string NOTIFICATION_CHANNEL_ID = "default_notification_channel_id";
    const string TAG = "MainActivity"; // For logging

    protected override void OnCreate(Bundle savedInstanceState)
    {
        base.OnCreate(savedInstanceState);

        // FirebaseApp.InitializeApp(this); // This is now handled by Plugin.Firebase in MauiProgram.cs
        // Log.Debug(TAG, "Firebase initialized successfully."); // Logging for direct init removed

        CreateNotificationChannel();
        AskForNotificationPermission();
    }

    void CreateNotificationChannel()
    {
        if (Build.VERSION.SdkInt < BuildVersionCodes.O)
        {
            // Notification channels are not available prior to Oreo.
            Log.Debug(TAG, "Notification channels not required prior to Oreo.");
            return;
        }

        var channelName = "Default Channel"; // In a real app, use Resources.GetString(Resource.String.default_notification_channel_name);
        var channelDescription = "Default channel for app notifications"; // Keep it simple or use strings.xml
        var channel = new NotificationChannel(NOTIFICATION_CHANNEL_ID, channelName, NotificationImportance.Default)
        {
            Description = channelDescription
        };
        // channel.EnableLights(true); // Optional: Configure lights
        // channel.LightColor = Color.Red; // Optional: Configure light color
        // channel.EnableVibration(true); // Optional: Configure vibration

        var notificationManager = (NotificationManager)GetSystemService(NotificationService);
        if (notificationManager != null)
        {
            notificationManager.CreateNotificationChannel(channel);
            Log.Debug(TAG, "Notification channel created: " + NOTIFICATION_CHANNEL_ID);
        }
        else
        {
            Log.Error(TAG, "Failed to get NotificationManager system service.");
        }
    }

    void AskForNotificationPermission()
    {
        if (Build.VERSION.SdkInt >= BuildVersionCodes.Tiramisu) // API level 33 for POST_NOTIFICATIONS
        {
            if (ContextCompat.CheckSelfPermission(this, global::Android.Manifest.Permission.PostNotifications) == Permission.Granted)
            {
                Log.Debug(TAG, "POST_NOTIFICATIONS permission already granted.");
            }
            else if (ShouldShowRequestPermissionRationale(global::Android.Manifest.Permission.PostNotifications))
            {
                Log.Debug(TAG, "Showing rationale for POST_NOTIFICATIONS permission.");
                // TODO: Display an educational UI explaining to the user the features that will be enabled
                // by them granting the POST_NOTIFICATION permission. This UI should provide the user
                // "OK" and "No thanks" buttons. If the user selects "OK," directly request the permission.
                // If the user selects "No thanks," allow the user to continue without notifications.
                // For now, we'll just request it.
                RequestPermissions(new[] { global::Android.Manifest.Permission.PostNotifications }, POST_NOTIFICATIONS_REQUEST_CODE); // Request code for POST_NOTIFICATIONS
            }
            else
            {
                Log.Debug(TAG, "Requesting POST_NOTIFICATIONS permission directly.");
                RequestPermissions(new[] { global::Android.Manifest.Permission.PostNotifications }, POST_NOTIFICATIONS_REQUEST_CODE); // Request code for POST_NOTIFICATIONS
            }
        }
        else
        {
            Log.Debug(TAG, "POST_NOTIFICATIONS permission not required before API 33.");
        }
    }

    public override void OnRequestPermissionsResult(int requestCode, string[] permissions, Permission[] grantResults)
    {
        if (requestCode == 0) // Our specific request code for POST_NOTIFICATIONS
        {
            if (grantResults.Length > 0 && grantResults[0] == Permission.Granted)
            {
                Log.Debug(TAG, "POST_NOTIFICATIONS permission granted by user.");
                // You can now safely post notifications.
            }
            else
            {
                Log.Debug(TAG, "POST_NOTIFICATIONS permission denied by user.");
                // TODO: Inform the user that certain features relying on notifications will be unavailable.
                // For example, by showing a Snackbar or a dialog.
            }
        }
        // It's crucial to call the base implementation so that MAUI (or other libraries)
        // can handle their own permission requests.
        base.OnRequestPermissionsResult(requestCode, permissions, grantResults);
    }
}
