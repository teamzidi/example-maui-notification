import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ForexChartView()
                .tabItem {
                    Label("為替チャート", systemImage: "chart.line.uptrend.xyaxis")
                }

            EconomicNewsView()
                .tabItem {
                    Label("経済ニュース", systemImage: "newspaper")
                }
        }
    }
}
