import Foundation

// 通貨ペアの種別を定義するenum (オプション、必要に応じて拡張)
enum ForexPair: String, CaseIterable, Identifiable {
    case mxnjpy = "MXN/JPY"
    case zarjpy = "ZAR/JPY"

    var id: String { self.rawValue }
}

// 単一の為替データポイントを表す構造体
struct ForexDataPoint: Identifiable {
    let id = UUID() // Identifiableプロトコル準拠
    let pairName: ForexPair // 通貨ペア名
    let date: Date       // 日時
    let high: Double     // 高値
    let low: Double      // 安値
    let open: Double     // 始値
    let close: Double    // 終値
}
