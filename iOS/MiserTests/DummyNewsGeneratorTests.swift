import XCTest
@testable import Miser // Replace 'Miser' with the actual module name

class DummyNewsGeneratorTests: XCTestCase {

    func testGenerateAllNews_ReturnsNonEmptyArray() {
        let newsItems = DummyNewsGenerator.generateAllNews()
        XCTAssertFalse(newsItems.isEmpty, "Generated news items array should not be empty.")
    }

    func testGenerateAllNews_ItemsHaveRequiredPropertiesSet() {
        let newsItems = DummyNewsGenerator.generateAllNews()
        XCTAssertFalse(newsItems.isEmpty, "Test requires generated news items.")

        for item in newsItems {
            // country and indicator are non-optional enum types, so they are always set.
            XCTAssertFalse(item.value.isEmpty, "News item value should not be empty for item ID \(item.id).")
            // publishedDate is non-optional Date, so it's always set.
            // We can check if the date is recent, e.g., not more than a few days in the past from now.
            let now = Date()
            // Dummy generator creates dates up to i*5 days ago, max i is 1 (0..<2), so max 5 days ago.
            // Let's give it a bit more buffer for safety in test.
            let reasonablePastDateLimit = Calendar.current.date(byAdding: .day, value: -15, to: now)!
            XCTAssertTrue(item.publishedDate >= reasonablePastDateLimit && item.publishedDate <= now, "Published date \(item.publishedDateString) for item ID \(item.id) (\(item.country.rawValue) - \(item.indicator.rawValue)) seems too old or in the future.")

            // Optional properties notes and sourceLink can be nil, so no check for non-nil here unless specific items are expected to have them.
        }
    }

    func testGenerateAllNews_ItemsAreSortedCorrectly() {
        let newsItems = DummyNewsGenerator.generateAllNews()
        guard newsItems.count > 1 else {
            XCTFail("Need more than 1 item to test sorting. Generated \(newsItems.count) items.")
            return
        }

        for i in 0..<(newsItems.count - 1) {
            let currentItem = newsItems[i]
            let nextItem = newsItems[i+1]

            // Primary sort: Date descending
            if currentItem.publishedDate != nextItem.publishedDate {
                XCTAssertGreaterThanOrEqual(currentItem.publishedDate, nextItem.publishedDate, "News items should be sorted by publishedDate descending primarily. Failed for \(currentItem.id) and \(nextItem.id).")
            }
            // Secondary sort: Country rawValue ascending (if dates are same)
            else if currentItem.country.rawValue != nextItem.country.rawValue {
                 XCTAssertLessThanOrEqual(currentItem.country.rawValue, nextItem.country.rawValue, "For same date, items should be sorted by country ascending. Failed for \(currentItem.id) (\(currentItem.country.rawValue)) and \(nextItem.id) (\(nextItem.country.rawValue)).")
            }
            // Tertiary sort: Indicator rawValue ascending (if dates and countries are same)
            else {
                 XCTAssertLessThanOrEqual(currentItem.indicator.rawValue, nextItem.indicator.rawValue, "For same date and country, items should be sorted by indicator ascending. Failed for \(currentItem.id) (\(currentItem.indicator.rawValue)) and \(nextItem.id) (\(nextItem.indicator.rawValue)).")
            }
        }
    }

    func testGenerateAllNews_ValuesArePlausible() {
        let newsItems = DummyNewsGenerator.generateAllNews()
        XCTAssertFalse(newsItems.isEmpty, "Test requires generated news items.")

        for item in newsItems {
            switch item.indicator {
            case .cpi:
                XCTAssertTrue(item.value.contains("%") && item.value.contains("前年同月比"), "CPI value '\(item.value)' for ID \(item.id) doesn't seem plausible.")
            case .interestRate:
                XCTAssertTrue(item.value.contains("%"), "Interest rate value '\(item.value)' for ID \(item.id) doesn't seem plausible (missing '%').")
            case .tradeBalance:
                let hasNumber = item.value.rangeOfCharacter(from: .decimalDigits) != nil
                let hasOku = item.value.contains("億")

                let currencyCode: String
                switch item.country {
                case .japan: currencyCode = "JPY"
                case .usa: currencyCode = "USD"
                case .mexico: currencyCode = "MXN"
                case .southAfrica: currencyCode = "ZAR"
                }
                let hasCurrency = item.value.contains(currencyCode)

                XCTAssertTrue(hasNumber && hasOku && hasCurrency, "Trade balance value '\(item.value)' for ID \(item.id) (country: \(item.country.rawValue), expected currency: \(currencyCode)) doesn't seem plausible.")
            }
        }
    }
}
