import Charts
import KostenErfasserCore
import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query private var expenses: [Expense]
    @Query(sort: \ExpenseCategory.sortOrder) private var categories: [ExpenseCategory]
    @State private var kind: PeriodKind = .month
    @State private var anchor: Date = .now

    private let calendar = Calendar.kostenErfasser()

    var body: some View {
        let records = expenses.map(\.record)
        let period = Period.containing(anchor, kind: kind, calendar: calendar)
        let totals = StatisticsEngine.totalsByCategory(records, in: period)
        let periodTotal = StatisticsEngine.total(records, in: period)
        let months = StatisticsEngine.series(records, kind: .month, count: 12, endingWith: anchor, calendar: calendar)

        NavigationStack {
            List {
                Section {
                    Picker("Zeitraum", selection: $kind) {
                        ForEach(PeriodKind.allCases, id: \.self) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    HStack {
                        Button {
                            anchor = period.previous(calendar: calendar).start
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        Spacer()
                        Text(PeriodFormatter.title(for: period, calendar: calendar))
                            .font(.headline)
                        Spacer()
                        Button {
                            anchor = period.next(calendar: calendar).start
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .buttonStyle(.borderless)
                    LabeledContent("Summe", value: periodTotal.formatted())
                }

                if totals.isEmpty {
                    Section {
                        Text("Keine Ausgaben in diesem Zeitraum.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section("Nach Kategorien") {
                        Chart(totals, id: \.categoryID) { total in
                            SectorMark(
                                angle: .value("Betrag", chartValue(total.amount)),
                                innerRadius: .ratio(0.6),
                                angularInset: 1
                            )
                            .foregroundStyle(Color(hex: category(for: total.categoryID)?.colorHex ?? "#757575"))
                        }
                        .frame(height: 220)
                        ForEach(totals, id: \.categoryID) { total in
                            CategoryTotalRow(total: total, category: category(for: total.categoryID))
                        }
                    }
                }

                Section("Letzte 12 Monate") {
                    Chart(months, id: \.period.start) { month in
                        BarMark(
                            x: .value("Monat", month.period.start, unit: .month),
                            y: .value("Betrag", chartValue(month.amount))
                        )
                    }
                    .frame(height: 200)
                }
            }
            .navigationTitle("Statistik")
        }
    }

    private func category(for id: UUID?) -> ExpenseCategory? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    /// Charts need a floating point value; it is used for drawing only, never for sums.
    private func chartValue(_ money: Money) -> Double {
        Double(money.cents) / 100
    }
}
