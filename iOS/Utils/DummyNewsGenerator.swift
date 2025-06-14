import Foundation

struct DummyNewsGenerator {

    static func generateAllNews() -> [EconomicNewsItem] {
        var allNews: [EconomicNewsItem] = []
        let calendar = Calendar.current
        let today = Date()

        for country in NewsCountry.allCases {
            for indicator in NewsIndicator.allCases {
                // Generate 1 or 2 recent news items for each combination
                for i in 0..<Int.random(in: 1...2) {
                    guard let date = calendar.date(byAdding: .day, value: -(i * Int.random(in: 1...5)), to: today) else { // Random recent days
                        continue
                    }

                    let value = generateValue(for: indicator, country: country)
                    let notes = generateNotes(for: indicator)
                    let link = generateSourceLink(for: country, indicator: indicator)

                    allNews.append(EconomicNewsItem(
                        country: country,
                        indicator: indicator,
                        value: value,
                        publishedDate: date,
                        notes: notes,
                        sourceLink: link
                    ))
                }
            }
        }
        // Sort by date, most recent first, then by country, then by indicator
        return allNews.sorted {
            if $0.publishedDate != $1.publishedDate {
                return $0.publishedDate > $1.publishedDate
            } else if $0.country.rawValue != $1.country.rawValue {
                return $0.country.rawValue < $1.country.rawValue
            } else {
                return $0.indicator.rawValue < $1.indicator.rawValue
            }
        }
    }

    private static func generateValue(for indicator: NewsIndicator, country: NewsCountry) -> String {
        let randomPercentage = String(format: "%.1f%%", Double.random(in: -5.0...5.0))
        let randomPositivePercentage = String(format: "%.1f%%", Double.random(in: 0.5...5.0))
        let randomRate = String(format: "%.2f%%", Double.random(in: 0.1...7.5))

        let currency: String
        switch country {
        case .japan: currency = "JPY"
        case .usa: currency = "USD"
        case .mexico: currency = "MXN"
        case .southAfrica: currency = "ZAR"
        }
        // Simplified trade balance, could be more specific (e.g., "億" + currency)
        let randomTradeBalance = "\(Int.random(in: -500...500))億 \(currency)"


        switch indicator {
        case .tradeBalance:
            return randomTradeBalance
        case .interestRate:
            return randomRate
        case .cpi:
            return "\(randomPercentage) (前年同月比)"
        }
    }

    private static func generateNotes(for indicator: NewsIndicator) -> String? {
        let notesPool = [
            "市場予想を上回る結果となりました。",
            "市場予想を下回りました。",
            "ほぼ予想通りの数値です。",
            "今後の経済動向に注目が集まります。",
            nil, // Occasionally no notes
            "詳細はレポートをご確認ください。"
        ]
        return notesPool.randomElement()! // Force unwrap as nil is a valid element
    }

    private static func generateSourceLink(for country: NewsCountry, indicator: NewsIndicator) -> URL? {
        // Dummy URLs, replace with actual sources if available
        let urls = [
            "https://www.example-news.com/\(country.rawValue.lowercased())/\(indicator.rawValue.lowercased().filter {!$0.isWhitespace})",
            "https://www.another-source.org/reports/\(country.rawValue.lowercased())/latest-\(indicator.rawValue.lowercased().filter {!$0.isWhitespace}).html",
            nil // Occasionally no link
        ]
        if let urlString = urls.randomElement() as? String {
            return URL(string: urlString)
        }
        return nil
    }
}
