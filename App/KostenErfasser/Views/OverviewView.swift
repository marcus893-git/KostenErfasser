import KostenErfasserCore
import SwiftData
import SwiftUI

struct OverviewView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \ExpenseCategory.sortOrder) private var categories: [ExpenseCategory]

    private let calendar = Calendar.kostenErfasser()

    var body: some View {
        let now = Date.now
        let records = expenses.map(\.record)
        let month = Period.containing(now, kind: .month, calendar: calendar)
        let comparison = StatisticsEngine.monthToDate(records, now: now, calendar: calendar)
        let topCategories = Array(StatisticsEngine.totalsByCategory(records, in: month).prefix(5))

        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(PeriodFormatter.title(for: month, calendar: calendar))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(comparison.current.formatted())
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .monospacedDigit()
                        Text(changeText(comparison))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                if !topCategories.isEmpty {
                    Section("Größte Kategorien im Monat") {
                        ForEach(topCategories, id: \.categoryID) { total in
                            CategoryTotalRow(total: total, category: category(for: total.categoryID))
                        }
                    }
                }
                Section("Letzte Buchungen") {
                    if expenses.isEmpty {
                        Text("Noch keine Ausgaben erfasst.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(expenses.prefix(5)) { expense in
                        ExpenseRow(expense: expense)
                    }
                }
            }
            .navigationTitle("Übersicht")
        }
    }

    private func category(for id: UUID?) -> ExpenseCategory? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    private func changeText(_ comparison: MonthToDateComparison) -> String {
        guard let ratio = comparison.changeRatio else {
            return "Im Vormonat gab es bis zum selben Tag keine Ausgaben."
        }
        let percent = abs(ratio).formatted(.percent.precision(.fractionLength(0)))
        let direction = ratio >= 0 ? "mehr" : "weniger"
        return "\(percent) \(direction) als im Vormonat bis zum selben Tag (\(comparison.previous.formatted()))"
    }
}
