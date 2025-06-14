import XCTest
@testable import Miser // Replace 'Miser' with the actual module name of your app

class ForexViewModelTests: XCTestCase {

    var sut: ForexViewModel! // System Under Test

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Initialize sut here if it's expensive or needs to be reset cleanly for each test.
        // For this ViewModel, re-initializing in each test is fine.
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testInitialization_LoadsDefaultData() {
        sut = ForexViewModel() // Default init: .mxnjpy, .thirtyDays

        // Expectations for Combine publishers can be tricky without a helper library.
        // For simplicity, we'll check after a brief delay or rely on synchronous dummy data.
        // DummyDataGenerator is synchronous, so data should be available immediately after init.

        XCTAssertFalse(sut.chartDataPoints.isEmpty, "Chart data should be loaded on initialization.")
        XCTAssertEqual(sut.selectedPair, .mxnjpy, "Default pair should be .mxnjpy.")
        XCTAssertEqual(sut.selectedPeriod, .thirtyDays, "Default period should be .thirtyDays.")
        XCTAssertEqual(sut.chartDataPoints.count, DummyDataGenerator.days(for: .thirtyDays), "Data count should match default period (30 days).")
    }

    func testUpdatePair_ReloadsDataCorrectly() {
        sut = ForexViewModel(initialPair: .mxnjpy, initialPeriod: .tenDays) // Start with a known state
        let initialDataCount = sut.chartDataPoints.count
        XCTAssertEqual(initialDataCount, DummyDataGenerator.days(for: .tenDays))
        if let firstPointPair = sut.chartDataPoints.first?.pairName {
             XCTAssertEqual(firstPointPair, .mxnjpy, "Initial data should be for mxnjpy.")
        }


        sut.updatePair(to: .zarjpy)

        XCTAssertEqual(sut.selectedPair, .zarjpy, "Selected pair should be updated to .zarjpy.")
        // Data should be reloaded for the new pair, count should remain for the same period
        XCTAssertEqual(sut.chartDataPoints.count, DummyDataGenerator.days(for: .tenDays), "Data count should still match the initial period (10 days) for the new pair.")
        XCTAssertFalse(sut.chartDataPoints.isEmpty, "Chart data should not be empty after pair update.")
        if let firstPointPairAfterUpdate = sut.chartDataPoints.first?.pairName {
            XCTAssertEqual(firstPointPairAfterUpdate, .zarjpy, "Updated data should be for .zarjpy.")
        }
    }

    func testUpdatePeriod_ReloadsDataCorrectly() {
        sut = ForexViewModel(initialPair: .mxnjpy, initialPeriod: .tenDays)
        XCTAssertEqual(sut.chartDataPoints.count, DummyDataGenerator.days(for: .tenDays))

        sut.updatePeriod(to: .thirtyDays)

        XCTAssertEqual(sut.selectedPeriod, .thirtyDays, "Selected period should be updated to .thirtyDays.")
        XCTAssertEqual(sut.chartDataPoints.count, DummyDataGenerator.days(for: .thirtyDays), "Data count should match the new period (30 days).")
        XCTAssertFalse(sut.chartDataPoints.isEmpty, "Chart data should not be empty after period update.")
         if let firstPointPair = sut.chartDataPoints.first?.pairName {
             XCTAssertEqual(firstPointPair, .mxnjpy, "Data should still be for the initial pair (mxnjpy) after period update.")
        }
    }

    func testDataPointCount_MatchesSelectedPeriod_ForAllPeriods() {
        sut = ForexViewModel(initialPair: .mxnjpy, initialPeriod: .tenDays) // Start with any period

        for period in ChartPeriod.allCases {
            sut.updatePeriod(to: period)
            XCTAssertEqual(sut.chartDataPoints.count, DummyDataGenerator.days(for: period), "Data count for \(period.rawValue) should be \(DummyDataGenerator.days(for: period)).")
        }
    }

    func testChartDataPoints_AreForSelectedPair() {
        sut = ForexViewModel(initialPair: .mxnjpy, initialPeriod: .tenDays)

        // Check initial pair
        for dataPoint in sut.chartDataPoints {
            XCTAssertEqual(dataPoint.pairName, .mxnjpy, "All data points should be for MXN/JPY initially.")
        }

        // Change pair and check again
        sut.updatePair(to: .zarjpy)
        for dataPoint in sut.chartDataPoints {
            XCTAssertEqual(dataPoint.pairName, .zarjpy, "All data points should be for ZAR/JPY after update.")
        }
    }
}

// Make sure ForexViewModel, ForexPair, ChartPeriod, DummyDataGenerator, ForexDataPoint are accessible.
// This might require them to have public or internal access levels and the app module to be imported with @testable.
// The module name 'Miser' in '@testable import Miser' should match your project's module name.
