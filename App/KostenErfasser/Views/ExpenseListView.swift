import KostenErfasserCore
import SwiftData
import SwiftUI

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var searchText = ""

    private var filtered: [Expense] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return expenses }
        return expenses.filter { expense in
            [expense.title, expense.merchant ?? "", expense.note ?? "", expense.category?.name ?? ""]
                .contains { $0.localizedStandardContains(query) }
        }
    }

    private var days: [DayGroup] {
        let calendar = Calendar.kostenErfasser()
        let groups = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }
        return groups.keys.sorted(by: >).map { DayGroup(day: $0, expenses: groups[$0] ?? []) }
    }

    var body: some View {
        NavigationStack {
            List {
                if !filtered.isEmpty {
                    Section {
                        LabeledContent("Summe", value: filtered.map(\.amount).sum().formatted())
                            .bold()
                    }
                }
                ForEach(days) { group in
                    Section(group.day.formatted(date: .complete, time: .omitted)) {
                        ForEach(group.expenses) { expense in
                            NavigationLink(value: expense) {
                                ExpenseRow(expense: expense)
                            }
                        }
                        .onDelete { offsets in
                            delete(offsets.map { group.expenses[$0] })
                        }
                    }
                }
            }
            .overlay {
                if expenses.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Ausgaben", systemImage: "tray",
                        description: Text("Erfasse deine erste Ausgabe im Tab „Erfassen“."))
                } else if filtered.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText, prompt: "Beschreibung, Händler, Kategorie")
            .navigationTitle("Ausgaben")
            .navigationDestination(for: Expense.self) { expense in
                ExpenseEditorView(expense: expense)
            }
        }
    }

    private func delete(_ items: [Expense]) {
        for item in items {
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}

private struct DayGroup: Identifiable {
    let day: Date
    let expenses: [Expense]
    var id: Date { day }
}
