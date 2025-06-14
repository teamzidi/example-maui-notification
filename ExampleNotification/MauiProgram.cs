using Microsoft.Extensions.Logging;
using Plugin.Firebase.Core; // Required for CrossFirebase.Initialize

#if IOS
using Plugin.Firebase.Core.Platforms.iOS;
#elif ANDROID
using Plugin.Firebase.Core.Platforms.Android;
#endif

namespace ExampleNotification;

public static class MauiProgram
{
	public static MauiApp CreateMauiApp()
	{
		var builder = MauiApp.CreateBuilder();
		builder
			.UseMauiApp<App>()
			.ConfigureFonts(fonts =>
			{
				fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
				fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
			})
			.RegisterFirebaseServices(); // Added this line

#if DEBUG
		builder.Logging.AddDebug();
#endif

		return builder.Build();
	}

	// Added this extension method
	private static MauiAppBuilder RegisterFirebaseServices(this MauiAppBuilder builder)
	{
		builder.ConfigureLifecycleEvents(events => {
#if IOS
			events.AddiOS(iOS => iOS.WillFinishLaunching((_,__) => {
				CrossFirebase.Initialize(); // For iOS
				return false;
			}));
#elif ANDROID
			events.AddAndroid(android => android.OnCreate((activity, _) =>
				CrossFirebase.Initialize(activity))); // For Android, passing the activity
#endif
		});

		// As per the subtask description, not including CrossFirebaseAuth.Current registration
		// as the primary focus is Cloud Messaging.
		// If Plugin.Firebase.CloudMessaging requires a specific service registration like:
		// builder.Services.AddSingleton(_ => CrossFirebaseCloudMessaging.Current);
		// it would be added here, but it's not indicated by current plugin documentation
		// for basic FCM setup via Plugin.Firebase.

		return builder;
	}
}
