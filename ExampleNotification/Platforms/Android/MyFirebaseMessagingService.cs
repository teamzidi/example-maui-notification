using Android.App;
using Android.Content;
using Android.OS;
using Android.Util;
using Firebase.Messaging;
using System;

namespace ExampleNotification.Platforms.Android
{
    [Service(Exported = false)]
    [IntentFilter(new[] { "com.google.firebase.MESSAGING_EVENT" })]
    public class MyFirebaseMessagingService : FirebaseMessagingService
    {
        const string TAG = "MyFirebaseMsgService";

        public override void OnNewToken(string token)
        {
            Log.Debug(TAG, "FCM token: " + token);
            // TODO: Send token to your app server
        }

        public override void OnMessageReceived(RemoteMessage message)
        {
            Log.Debug(TAG, "From: " + message.From);
            Log.Debug(TAG, "Notification Message Body: " + message.GetNotification()?.Body);

            // TODO: Handle foreground messages and display notifications
            // This is where you would create and display a local notification
            // if the app is in the foreground.
            // For background messages, Android will handle the notification display
            // based on the message payload, using the defaults set in AndroidManifest.xml
            // and the notification channel created in MainActivity.
        }
    }
}
