# example-maui-notification

This is a MAUI application.

## プッシュ通知仕様 (iOS)

iOSアプリはバックエンドサービスから送信されるプッシュ通知を受信して、OSの通知センターに表示します。以下は、アプリが期待するプッシュ通知のペイロード形式です。

### ペイロード形式

```json
{
  "aps": {
    "alert": {
      "title": "為替アラート",
      "body": "MXN/JPY が過去1ヶ月平均より10%下落しました！"
    },
    "sound": "default",
    "badge": 1
  },
  "notification_type": "PRICE_ALERT",
  "currency_pair": "MXN/JPY",
  "event_time": "2023-10-27T17:00:00Z",
  "details": {
    "current_price": 7.5,
    "monthly_average": 8.33
  }
}
```

### キーの説明

*   **`aps`** (オブジェクト): Apple Push Notification service (APNs) が使用する予約済みのキー。
    *   **`alert`** (オブジェクト): 通知の表示内容。
        *   **`title`** (文字列): 通知のタイトル。
        *   **`body`** (文字列): 通知の本文。
    *   **`sound`** (文字列): 通知音。`default` を指定すると標準の通知音が鳴ります。
    *   **`badge`** (数値, オプション): アプリアイコンに表示するバッジナンバー。
*   **`notification_type`** (文字列): 通知の種類を識別するためのカスタムキー。例: `PRICE_ALERT`。
*   **`currency_pair`** (文字列): 通知に関連する通貨ペア。例: `MXN/JPY`。
*   **`event_time`** (文字列): イベント（例: 価格アラート条件合致）が発生した時刻 (ISO 8601形式)。
*   **`details`** (オブジェクト, オプション): 通知に関する追加の詳細情報を含むカスタムオブジェクト。
    *   **`current_price`** (数値, オプション): イベント発生時の現在価格。
    *   **`monthly_average`** (数値, オプション): イベント発生時の月間平均価格。
