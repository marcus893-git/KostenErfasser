import SwiftData
import SwiftUI

enum AppTab: Hashable {
    case overview
    case expenses
    case add
    case statistics
    case settings
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .overview

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Übersicht", systemImage: "house", value: AppTab.overview) {
                OverviewView()
            }
            Tab("Ausgaben", systemImage: "list.bullet", value: AppTab.expenses) {
                ExpenseListView()
            }
            Tab("Erfassen", systemImage: "plus.circle.fill", value: AppTab.add) {
                NavigationStack {
                    ExpenseEditorView(expense: nil) {
                        selectedTab = .expenses
                    }
                }
            }
            Tab("Statistik", systemImage: "chart.pie", value: AppTab.statistics) {
                StatisticsView()
            }
            Tab("Einstellungen", systemImage: "gearshape", value: AppTab.settings) {
                SettingsView()
            }
        }
        .task {
            CategorySeeder.seedIfNeeded(modelContext)
        }
    }
}
