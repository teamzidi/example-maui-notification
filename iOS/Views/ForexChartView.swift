import SwiftUI
import Charts // Import Swift Charts

struct ForexChartView: View {
    @StateObject private var viewModel = ForexViewModel()

    var body: some View {
        NavigationView { // For a title bar, can be adjusted based on app structure
            VStack {
                // Currency Pair Picker
                Picker("Currency Pair", selection: $viewModel.selectedPair) {
                    ForEach(ForexPair.allCases) { pair in
                        Text(pair.rawValue).tag(pair)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Or .automatic, .menu based on preference
                .padding(.horizontal)

                // Chart Period Picker
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(ChartPeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Chart Area
                if viewModel.isLoading {
                    ProgressView("Loading Chart...")
                        .frame(height: 300) // Give some space for the loader
                } else if viewModel.chartDataPoints.isEmpty {
                    Text("No data available for the selected period.")
                        .frame(height: 300)
                } else {
                    Chart {
                        ForEach(viewModel.chartDataPoints) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date, unit: .day), // Specify unit for date
                                y: .value("Price (Close)", dataPoint.close)
                            )
                            // Optional: Add AreaMark for a filled effect below the line
                            // AreaMark(
                            //     x: .value("Date", dataPoint.date, unit: .day),
                            //     yStart: .value("Min Price", viewModel.chartDataPoints.map{$0.low}.min() ?? 0), // Or a fixed baseline
                            //     yEnd: .value("Price (Close)", dataPoint.close)
                            // )
                            // .opacity(0.3)

                            // Optional: RuleMark for High/Low range (Candle Stick like)
                            // For a full candlestick, you'd typically use RectangleMark for the body
                            // and RuleMark for the wicks. Here's a simplified high/low line.
                            RuleMark(
                                x: .value("Date", dataPoint.date, unit: .day),
                                yStart: .value("Low", dataPoint.low),
                                yEnd: .value("High", dataPoint.high)
                            )
                            .foregroundStyle(Color.gray.opacity(0.5))
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: xStrideCount())) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.month().day(), centered: false)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in // Default ticks and lines
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel() // Default formatting for Double
                        }
                    }
                    .frame(height: 300) // Example height
                    .padding()
                }

                Spacer() // Push content to the top
            }
            .navigationTitle(viewModel.selectedPair.rawValue) // Display selected pair as title
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Helper function to determine X-axis stride based on period
    private func xStrideCount() -> Int {
        switch viewModel.selectedPeriod {
        case .tenDays:
            return 1 // Show every day
        case .thirtyDays:
            return 3 // Show every 3 days
        case .sixMonths:
            return 15 // Show every 15 days (approx twice a month)
        case .oneYear:
            return 30 // Show every 30 days (approx monthly)
        case .fiveYears:
            return 365 // Show approx yearly
        }
    }
}

// Preview Provider (Optional but recommended)
struct ForexChartView_Previews: PreviewProvider {
    static var previews: some View {
        ForexChartView()
    }
}
