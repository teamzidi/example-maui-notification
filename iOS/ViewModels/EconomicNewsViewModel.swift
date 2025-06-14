import Foundation
import Combine

class EconomicNewsViewModel: ObservableObject {

    @Published var newsItemsByCountry: [NewsCountry: [EconomicNewsItem]] = [:]
    // To maintain a consistent order for sections in the View
    @Published var countries: [NewsCountry] = []
    @Published var isLoading: Bool = false

    init() {
        fetchNews()
    }

    func fetchNews() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let allNews = DummyNewsGenerator.generateAllNews()

            // Group news items by country
            let groupedNews = Dictionary(grouping: allNews, by: { $0.country })

            // Determine the order of countries for display
            // Option 1: All countries defined in NewsCountry.allCases, even if they have no news
            // let sortedCountries = NewsCountry.allCases

            // Option 2: Only countries that have news, sorted by their definition order in NewsCountry enum
            var presentCountries: [NewsCountry] = []
            for countryCase in NewsCountry.allCases { // Iterate in defined order
                if groupedNews[countryCase] != nil {
                    presentCountries.append(countryCase)
                }
            }

            DispatchQueue.main.async {
                self.newsItemsByCountry = groupedNews
                self.countries = presentCountries // Use the sorted list of countries that have news
                self.isLoading = false
            }
        }
    }
}
