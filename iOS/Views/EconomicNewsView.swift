import SwiftUI

struct EconomicNewsView: View {
    @StateObject private var viewModel = EconomicNewsViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("経済ニュースを読み込み中...")
                        .padding()
                } else if viewModel.countries.isEmpty {
                    Text("表示できる経済ニュースがありません。")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.countries) { country in
                            Section(header: Text(country.rawValue).font(.headline)) {
                                if let newsItems = viewModel.newsItemsByCountry[country], !newsItems.isEmpty {
                                    ForEach(newsItems) { item in
                                        newsItemRow(item: item)
                                    }
                                } else {
                                    // This case should ideally not happen if countries list is derived from non-empty newsItemsByCountry keys
                                    Text("この国のニュースはありません。")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle()) // Or .plain, .grouped
                }
            }
            .navigationTitle("経済ニュース")
            .navigationBarTitleDisplayMode(.inline) // Or .large
            // Optional: Add a refresh button if you want to manually trigger fetchNews
            // .toolbar {
            //     ToolbarItem(placement: .navigationBarTrailing) {
            //         Button {
            //             viewModel.fetchNews()
            //         } label: {
            //             Image(systemName: "arrow.clockwise")
            //         }
            //     }
            // }
        }
    }

    // Helper view for displaying a single news item row
    @ViewBuilder
    private func newsItemRow(item: EconomicNewsItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.indicator.descriptiveTitle)
                .font(.title3)
                .fontWeight(.semibold)

            HStack {
                Text("発表日:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(item.publishedDateString)
                    .font(.caption)
            }

            Text(item.value)
                .font(.body)
                .padding(.vertical, 2)

            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }

            if let link = item.sourceLink {
                Link("情報源を見る", destination: link)
                    .font(.caption)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 8) // Add some padding to each row
    }
}

// Preview Provider
struct EconomicNewsView_Previews: PreviewProvider {
    static var previews: some View {
        EconomicNewsView()
    }
}
