import SwiftUI

@main
struct HelpeApp: App {
    @StateObject private var store = PauseStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: PauseStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Pause", systemImage: "wind")
                }

            TargetsView()
                .tabItem {
                    Label("Targets", systemImage: "square.grid.2x2")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar")
                }
        }
    }
}
