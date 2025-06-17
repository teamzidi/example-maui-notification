using Plugin.Firebase.CloudMessaging;
using Microsoft.Maui.Clipboard; // Clipboard のために必要
using System; // For EventArgs, Exception, Task
using System.Diagnostics; // For Debug.WriteLine
// using Microsoft.Maui.Dispatching; // Not strictly needed if using MainThread static class

namespace ExampleNotification;

public partial class MainPage : ContentPage
{
    public MainPage()
    {
        InitializeComponent();
        // ページ初期化時にトークンを非同期で取得・表示し、イベントハンドラを設定
        InitializeFcmAsync();

        // フォアグラウンド通知受信イベントの購読
        CrossFirebaseCloudMessaging.Current.NotificationReceived += OnNotificationReceived;
        // トークン変更イベントの購読 (InitializeFcmAsync内でも行っているが、重複購読は通常問題ない。もしくはここで一元化も可)
        // CrossFirebaseCloudMessaging.Current.TokenChanged += OnTokenChanged;
    }

    protected override void OnAppearing()
    {
        base.OnAppearing();
        // OnAppearingでトークンを再確認・表示する（オプショナルだが、ページが再表示された場合に役立つことがある）
        // ただし、InitializeFcmAsyncで既にTokenChangedイベントを購読していれば不要かもしれない。
        // ここではシンプルに、初期化は一度きりとし、TokenChangedで更新する方針とします。
        // もしトークンがまだ取得できていない場合（例：初回起動時のネットワーク問題）、ここで再試行するのも良いでしょう。
        if (string.IsNullOrEmpty(TokenLabel.Text) || TokenLabel.Text == "Token not yet available." || TokenLabel.Text.StartsWith("Error"))
        {
            // FetchTokenButton_Clicked(null, null); // ボタンクリックと同じロジックで再取得
             _ = RefreshTokenAsync(); // UIをブロックしないように非同期で実行
        }
    }

    protected override void OnDisappearing()
    {
        // イベントハンドラの購読解除 (ページの生存期間中のみ購読する場合)
        // CrossFirebaseCloudMessaging.Current.NotificationReceived -= OnNotificationReceived;
        // CrossFirebaseCloudMessaging.Current.TokenChanged -= OnTokenChanged;
        // シングルトンなのでアプリ終了まで購読解除しないほうが良いかもしれない。ページごとに購読・解除すると複雑になる。
        base.OnDisappearing();
    }


    private async void InitializeFcmAsync()
    {
        // トークン変更イベントの購読
        CrossFirebaseCloudMessaging.Current.TokenChanged += OnTokenChanged;

        await RefreshTokenAsync();
    }

    private async Task RefreshTokenAsync()
    {
        MainThread.BeginInvokeOnMainThread(() => {
            TokenLabel.Text = "Fetching token...";
            CopyTokenButton.IsEnabled = false;
        });

        try
        {
            // 初期トークンの取得と表示
            var token = await CrossFirebaseCloudMessaging.Current.GetTokenAsync();
            if (!string.IsNullOrEmpty(token))
            {
                UpdateTokenDisplay(token);
            }
            else
            {
                UpdateTokenDisplay("Token not yet available.");
            }
        }
        catch (Exception ex)
        {
            UpdateTokenDisplay($"Error fetching token: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"[FCM Init/Refresh Error] {ex.ToString()}");
        }
    }


    private void OnTokenChanged(object sender, FCMTokenChangedEventArgs e)
    {
        MainThread.BeginInvokeOnMainThread(() =>
        {
            UpdateTokenDisplay(e.Token);
        });
    }

    private void UpdateTokenDisplay(string token)
    {
        // MainThread.BeginInvokeOnMainThread を呼び出し元で保証する方針に変更
        // またはここで再度 MainThread.BeginInvokeOnMainThread をかけても良いが、冗長になる可能性
        TokenLabel.Text = token;
        CopyTokenButton.IsEnabled = !string.IsNullOrEmpty(token) &&
                                  token != "Fetching token..." &&
                                  token != "Token not yet available." &&
                                  !token.StartsWith("Error");
        System.Diagnostics.Debug.WriteLine($"[FCM Token Updated] {token}");
        Console.WriteLine($"[FCM Token Updated Console] {token}"); // Console.WriteLineはデバッグビルドで確認しやすい
    }

    private async void FetchTokenButton_Clicked(object sender, EventArgs e)
    {
        await RefreshTokenAsync();
    }

    private async void CopyTokenButton_Clicked(object sender, EventArgs e)
    {
        if (CopyTokenButton.IsEnabled && !string.IsNullOrEmpty(TokenLabel.Text))
        {
            await Clipboard.SetTextAsync(TokenLabel.Text);
            SubscriptionStatusLabel.Text = "Token copied to clipboard!";
            // 短時間表示後にメッセージをクリアする（オプション）
            await Task.Delay(3000); // 3秒に延長
            if(SubscriptionStatusLabel.Text == "Token copied to clipboard!") // 他のメッセージで上書きされていないか確認
            {
                SubscriptionStatusLabel.Text = "";
            }
        }
        else
        {
            SubscriptionStatusLabel.Text = "No valid token to copy.";
        }
    }

    private async void SubscribeButton_Clicked(object sender, EventArgs e)
    {
        var topic = TopicEntry.Text;
        if (string.IsNullOrWhiteSpace(topic))
        {
            SubscriptionStatusLabel.Text = "Please enter a topic name.";
            return;
        }

        try
        {
            SubscriptionStatusLabel.Text = $"Subscribing to {topic}...";
            await CrossFirebaseCloudMessaging.Current.SubscribeToTopicAsync(topic);
            SubscriptionStatusLabel.Text = $"Subscribed to topic: {topic}";
            System.Diagnostics.Debug.WriteLine($"[FCM Topic] Subscribed to: {topic}");
        }
        catch (Exception ex)
        {
            SubscriptionStatusLabel.Text = $"Error subscribing to topic '{topic}': {ex.Message}";
            System.Diagnostics.Debug.WriteLine($"[FCM Topic Error] Subscribe {topic}: {ex.ToString()}");
        }
    }

    private async void UnsubscribeButton_Clicked(object sender, EventArgs e)
    {
        var topic = TopicEntry.Text;
        if (string.IsNullOrWhiteSpace(topic))
        {
            SubscriptionStatusLabel.Text = "Please enter a topic name.";
            return;
        }

        try
        {
            SubscriptionStatusLabel.Text = $"Unsubscribing from {topic}...";
            await CrossFirebaseCloudMessaging.Current.UnsubscribeFromTopicAsync(topic);
            SubscriptionStatusLabel.Text = $"Unsubscribed from topic: {topic}";
            System.Diagnostics.Debug.WriteLine($"[FCM Topic] Unsubscribed from: {topic}");
        }
        catch (Exception ex)
        {
            SubscriptionStatusLabel.Text = $"Error unsubscribing from topic '{topic}': {ex.Message}";
            System.Diagnostics.Debug.WriteLine($"[FCM Topic Error] Unsubscribe {topic}: {ex.ToString()}");
        }
    }

    private void OnNotificationReceived(object sender, FCMNotificationReceivedEventArgs e)
    {
        var title = e.Notification?.Title ?? "No Title";
        var body = e.Notification?.Body ?? "No Body";

        System.Diagnostics.Debug.WriteLine($"[FCM Notification Received in MainPage] Title: {title}, Body: {body}");
        Console.WriteLine($"[FCM Notification Received in MainPage Console] Title: {title}, Body: {body}"); // ReleaseビルドでもIDEのOutputで見れることがある

        // UIスレッドでLabelを更新
        MainThread.BeginInvokeOnMainThread(() =>
        {
            NotificationTitleLabel.Text = title;
            NotificationBodyLabel.Text = body;
        });

        if (e.Notification?.Data != null)
        {
            foreach (var key in e.Notification.Data.Keys)
            {
                var value = e.Notification.Data[key];
                System.Diagnostics.Debug.WriteLine($"[FCM Data in MainPage] {key} = {value}");
                Console.WriteLine($"[FCM Data in MainPage Console] {key} = {value}");
            }
        }
    }
}
