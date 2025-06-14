import Foundation

struct DummyDataGenerator {

    static func generateData(for pair: ForexPair, days: Int) -> [ForexDataPoint] {
        var dataPoints: [ForexDataPoint] = []
        let calendar = Calendar.current
        let today = Date()
        let basePrice: Double
        let volatility: Double // 価格変動の度合い

        switch pair {
        case .mxnjpy:
            basePrice = 8.0 // MXN/JPYのおおよその価格帯
            volatility = 0.15 // MXN/JPYの価格変動幅
        case .zarjpy:
            basePrice = 7.0 // ZAR/JPYのおおよその価格帯
            volatility = 0.20 // ZAR/JPYの価格変動幅
        }

        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else {
                continue
            }

            // 1日の始まりの価格（前日の終値を参考にすることもできるが、ここでは単純化）
            let openPrice: Double
            if let lastClose = dataPoints.last?.close, i > 0 {
                // 前日の終値から少し変動させる
                openPrice = lastClose + Double.random(in: -volatility/2...volatility/2)
            } else {
                openPrice = basePrice + Double.random(in: -volatility...volatility)
            }

            let highPrice = openPrice + Double.random(in: 0...volatility)
            let lowPrice = openPrice - Double.random(in: 0...volatility)
            // 終値は高値と安値の間でランダムに決定 (ただし、始値から大きく離れすぎないように調整も可能)
            let closePrice = Double.random(in: min(openPrice,lowPrice)...max(openPrice,highPrice))

            // 高値・安値が始値・終値の範囲を正しく含むように調整
            let actualHigh = max(highPrice, openPrice, closePrice)
            let actualLow = min(lowPrice, openPrice, closePrice)

            dataPoints.append(ForexDataPoint(
                pairName: pair,
                date: date,
                high: actualHigh,
                low: actualLow,
                open: openPrice,
                close: closePrice
            ))
        }
        // 日付昇順に並び替える
        return dataPoints.sorted { $0.date < $1.date }
    }

    // 事前に定義された期間に対応する日数を返すヘルパー
    static func days(for period: ChartPeriod) -> Int {
        switch period {
        case .tenDays: return 10
        case .thirtyDays: return 30
        case .sixMonths: return 180 // 約
        case .oneYear: return 365
        case .fiveYears: return 365 * 5
        }
    }
}

// チャート表示期間のenum (ViewModelやViewで使うことを想定)
enum ChartPeriod: String, CaseIterable, Identifiable {
    case tenDays = "10D"
    case thirtyDays = "30D"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case fiveYears = "5Y"

    var id: String { self.rawValue }
}
