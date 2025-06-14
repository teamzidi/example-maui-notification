import Foundation
import Combine // For ObservableObject and @Published

class ForexViewModel: ObservableObject {

    @Published var selectedPair: ForexPair {
        didSet {
            fetchChartData()
        }
    }
    @Published var selectedPeriod: ChartPeriod {
        didSet {
            fetchChartData()
        }
    }
    @Published var chartDataPoints: [ForexDataPoint] = []
    @Published var isLoading: Bool = false // Optional, for future API integration

    init(initialPair: ForexPair = .mxnjpy, initialPeriod: ChartPeriod = .thirtyDays) {
        self.selectedPair = initialPair
        self.selectedPeriod = initialPeriod
        fetchChartData() // Initial data load
    }

    func fetchChartData() {
        isLoading = true // Optional
        let days = DummyDataGenerator.days(for: selectedPeriod)
        // Generate data on a background thread to avoid blocking UI, though for dummy data it's very fast.
        // For real API calls, this would be essential.
        DispatchQueue.global(qos: .userInitiated).async {
            let generatedData = DummyDataGenerator.generateData(for: self.selectedPair, days: days)
            DispatchQueue.main.async {
                self.chartDataPoints = generatedData
                self.isLoading = false // Optional
            }
        }
    }

    func updatePair(to newPair: ForexPair) {
        guard self.selectedPair != newPair else { return } // Avoid redundant updates
        self.selectedPair = newPair
        // fetchChartData() will be called by didSet
    }

    func updatePeriod(to newPeriod: ChartPeriod) {
        guard self.selectedPeriod != newPeriod else { return } // Avoid redundant updates
        self.selectedPeriod = newPeriod
        // fetchChartData() will be called by didSet
    }
}
