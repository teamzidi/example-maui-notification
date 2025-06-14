import Foundation

enum NewsCountry: String, CaseIterable, Identifiable {
    case mexico = "メキシコ"
    case southAfrica = "南アフリカ"
    case japan = "日本"
    case usa = "アメリカ"

    var id: String { self.rawValue }
}

enum NewsIndicator: String, CaseIterable, Identifiable {
    case tradeBalance = "貿易収支"
    case interestRate = "金利"
    case cpi = "CPI (消費者物価指数)"
    // Add more indicators as needed

    var id: String { self.rawValue }

    // Helper to provide a more descriptive title if needed, or units
    var descriptiveTitle: String {
        switch self {
        case .tradeBalance:
            return "貿易収支"
        case .interestRate:
            return "政策金利"
        case .cpi:
            return "消費者物価指数 (前年同月比)"
        }
    }
}

struct EconomicNewsItem: Identifiable {
    let id = UUID()
    let country: NewsCountry
    let indicator: NewsIndicator
    let value: String // Example: "+2.5%", "120億USDの黒字", "5.25%"
    let publishedDate: Date
    let notes: String? // Optional field for more details or context
    let sourceLink: URL? // Optional link to the source of the news

    // Formatter for displaying dates
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        // formatter.locale = Locale(identifier: "ja_JP") // Uncomment if Japanese locale is desired
        return formatter
    }

    var publishedDateString: String {
        return Self.dateFormatter.string(from: publishedDate)
    }
}
