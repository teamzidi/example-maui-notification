import XCTest
@testable import Miser // Replace 'Miser' with the actual module name

class DummyDataGeneratorTests: XCTestCase {

    func testGenerateData_ReturnsCorrectNumberOfDays() {
        let daysToTest = [1, 10, 30, 180, 365]
        let pairsToTest: [ForexPair] = [.mxnjpy, .zarjpy]

        for pair in pairsToTest {
            for days in daysToTest {
                let dataPoints = DummyDataGenerator.generateData(for: pair, days: days)
                XCTAssertEqual(dataPoints.count, days, "Should generate \(days) data points for \(pair.rawValue), but got \(dataPoints.count).")
            }
        }
    }

    func testGenerateData_DataPointsAreSortedByDateAscending() {
        let dataPointsMxnjpy = DummyDataGenerator.generateData(for: .mxnjpy, days: 30)
        XCTAssertTrue(dataPointsMxnjpy.count > 1, "Need more than 1 data point to test sorting.")
        for i in 0..<(dataPointsMxnjpy.count - 1) {
            XCTAssertLessThanOrEqual(dataPointsMxnjpy[i].date, dataPointsMxnjpy[i+1].date, "MXN/JPY data points should be sorted by date ascending.")
        }

        let dataPointsZarjpy = DummyDataGenerator.generateData(for: .zarjpy, days: 30)
        XCTAssertTrue(dataPointsZarjpy.count > 1, "Need more than 1 data point to test sorting.")
        for i in 0..<(dataPointsZarjpy.count - 1) {
            XCTAssertLessThanOrEqual(dataPointsZarjpy[i].date, dataPointsZarjpy[i+1].date, "ZAR/JPY data points should be sorted by date ascending.")
        }
    }

    func testGenerateData_OHLCLogicIsValid() {
        let dataPoints = DummyDataGenerator.generateData(for: .mxnjpy, days: 30)
        XCTAssertFalse(dataPoints.isEmpty, "Generated data should not be empty.")

        for point in dataPoints {
            XCTAssertGreaterThanOrEqual(point.high, point.open, "High should be >= Open for \(point.date)")
            XCTAssertGreaterThanOrEqual(point.high, point.close, "High should be >= Close for \(point.date)")
            XCTAssertGreaterThanOrEqual(point.high, point.low, "High should be >= Low for \(point.date)")

            XCTAssertLessThanOrEqual(point.low, point.open, "Low should be <= Open for \(point.date)")
            XCTAssertLessThanOrEqual(point.low, point.close, "Low should be <= Close for \(point.date)")

            // Check that open and close are within high/low range
            XCTAssertGreaterThanOrEqual(point.open, point.low, "Open should be >= Low for \(point.date)")
            XCTAssertLessThanOrEqual(point.open, point.high, "Open should be <= High for \(point.date)")
            XCTAssertGreaterThanOrEqual(point.close, point.low, "Close should be >= Low for \(point.date)")
            XCTAssertLessThanOrEqual(point.close, point.high, "Close should be <= High for \(point.date)")
        }
    }

    func testGenerateData_PairNameIsCorrect() {
        let mxnData = DummyDataGenerator.generateData(for: .mxnjpy, days: 10)
        for point in mxnData {
            XCTAssertEqual(point.pairName, .mxnjpy, "All data points should have pairName .mxnjpy.")
        }

        let zarData = DummyDataGenerator.generateData(for: .zarjpy, days: 10)
        for point in zarData {
            XCTAssertEqual(point.pairName, .zarjpy, "All data points should have pairName .zarjpy.")
        }
    }

    func testDaysForPeriod_ReturnsCorrectValues() {
        XCTAssertEqual(DummyDataGenerator.days(for: .tenDays), 10)
        XCTAssertEqual(DummyDataGenerator.days(for: .thirtyDays), 30)
        XCTAssertEqual(DummyDataGenerator.days(for: .sixMonths), 180) // Approx.
        XCTAssertEqual(DummyDataGenerator.days(for: .oneYear), 365)
        XCTAssertEqual(DummyDataGenerator.days(for: .fiveYears), 365 * 5)
    }

    func testGenerateData_DifferentBasePricesForPairs() {
        // This test is a bit more heuristic, checking general price ranges
        let mxnData = DummyDataGenerator.generateData(for: .mxnjpy, days: 30)
        let zarData = DummyDataGenerator.generateData(for: .zarjpy, days: 30)

        XCTAssertFalse(mxnData.isEmpty)
        XCTAssertFalse(zarData.isEmpty)

        // Calculate average close price for MXN/JPY
        let avgCloseMxnjpy = mxnData.reduce(0.0) { $0 + $1.close } / Double(mxnData.count)
        // Calculate average close price for ZAR/JPY
        let avgCloseZarjpy = zarData.reduce(0.0) { $0 + $1.close } / Double(zarData.count)

        // Assuming MXN/JPY (e.g., ~8.0) is generally higher than ZAR/JPY (e.g., ~7.0) as per generator's basePrice
        // Allow for some overlap due to randomness, so not a strict inequality test
        // A more robust test would check against the basePrice +/- volatility range if those were exposed
        // For now, let's check they are not identical and somewhat different,
        // which implies different base prices were likely used.
        XCTAssertNotEqual(avgCloseMxnjpy, avgCloseZarjpy, "Average prices for MXN/JPY and ZAR/JPY should differ, implying different base prices.")
        // A slightly more specific check based on the known base prices (8.0 and 7.0)
        // This is still a bit fragile if randomness is very high.
        XCTAssertTrue(avgCloseMxnjpy > 6.0 && avgCloseMxnjpy < 10.0, "MXN/JPY avg price seems out of expected range (around 8.0)")
        XCTAssertTrue(avgCloseZarjpy > 5.0 && avgCloseZarjpy < 9.0, "ZAR/JPY avg price seems out of expected range (around 7.0)")

    }
}
