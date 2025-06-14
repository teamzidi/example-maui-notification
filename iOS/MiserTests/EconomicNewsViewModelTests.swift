import XCTest
@testable import Miser // Replace 'Miser' with the actual module name

class EconomicNewsViewModelTests: XCTestCase {

    var sut: EconomicNewsViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // For this ViewModel, re-initializing in each test is fine.
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testInitialization_LoadsAndGroupsNewsData() {
        sut = EconomicNewsViewModel()

        // DummyNewsGenerator is synchronous, so data should be available.
        XCTAssertFalse(sut.isLoading, "isLoading should be false after initialization.")

        // Check if countries list is populated (assuming DummyNewsGenerator provides data for some countries)
        // If DummyNewsGenerator *might* return no news, this test needs adjustment.
        // Assuming it always generates some news:
        XCTAssertFalse(sut.countries.isEmpty, "Countries list should not be empty if dummy news is generated.")
        XCTAssertFalse(sut.newsItemsByCountry.isEmpty, "News items by country dictionary should not be empty.")

        // Verify that the number of countries in the list matches the number of groups in the dictionary
        XCTAssertEqual(sut.countries.count, sut.newsItemsByCountry.keys.count, "Count of countries in list should match keys in dictionary.")
    }

    func testNewsData_IsGroupedCorrectlyByCountry() {
        sut = EconomicNewsViewModel()
        XCTAssertFalse(sut.newsItemsByCountry.isEmpty, "News items should be loaded.")

        for (countryKey, newsItems) in sut.newsItemsByCountry {
            XCTAssertFalse(newsItems.isEmpty, "News item list for country \(countryKey.rawValue) should not be empty if the country key exists.")
            for item in newsItems {
                XCTAssertEqual(item.country, countryKey, "Each news item in the list for \(countryKey.rawValue) should belong to that country.")
            }
        }
    }

    func testCountriesList_OrderAndContent() {
        sut = EconomicNewsViewModel()
        // Assuming DummyNewsGenerator generates news for all countries in NewsCountry.allCases for this test to be robust.
        // If not, the test should only check that sut.countries is a subset of NewsCountry.allCases and maintains the order.

        let expectedCountries = NewsCountry.allCases.filter { sut.newsItemsByCountry[$0]?.isEmpty == false }

        XCTAssertEqual(sut.countries.count, expectedCountries.count, "ViewModel's countries count should match expected countries with news.")
        XCTAssertEqual(sut.countries, expectedCountries, "ViewModel's countries should be the expected countries (those with news, in enum order).")
    }

    func testNewsItems_ArePresentAfterLoading() { // Renamed for clarity based on previous notes
        sut = EconomicNewsViewModel()
        // The DummyNewsGenerator sorts its overall output. The ViewModel groups this data.
        // This test ensures that after grouping, there are still news items present.

        var totalItems = 0
        for country in sut.countries {
            if let items = sut.newsItemsByCountry[country] {
                totalItems += items.count
                // Optionally, check if items within this specific group are sorted if that's a ViewModel responsibility.
                // As of now, ViewModel doesn't re-sort items within the group. DummyNewsGenerator sorts the initial flat list.
            }
        }
        XCTAssertTrue(totalItems > 0, "There should be at least one news item in total across all grouped countries.")

        // Further check: ensure that for each country in sut.countries, there's a non-empty list in newsItemsByCountry
        for country in sut.countries {
            XCTAssertNotNil(sut.newsItemsByCountry[country], "Country \(country.rawValue) listed in `countries` should have an entry in `newsItemsByCountry`.")
            XCTAssertFalse(sut.newsItemsByCountry[country]!.isEmpty, "News items for country \(country.rawValue) should not be empty.")
        }
    }
}
