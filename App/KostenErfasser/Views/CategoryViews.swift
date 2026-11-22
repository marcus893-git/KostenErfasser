import KostenErfasserCore
import SwiftUI

struct CategoryIcon: View {
    let symbolName: String
    let colorHex: String

    var body: some View {
        Image(systemName: symbolName)
            .font(.body)
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(Color(hex: colorHex), in: .rect(cornerRadius: 8))
    }
}

extension CategoryIcon {
    init(category: ExpenseCategory?) {
        self.init(symbolName: category?.symbolName ?? "questionmark", colorHex: category?.colorHex ?? "#757575")
    }
}

struct CategoryTotalRow: View {
    let total: CategoryTotal
    let category: ExpenseCategory?

    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: category)
            VStack(alignment: .leading, spacing: 2) {
                Text(category?.name ?? "Ohne Kategorie")
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(total.amount.formatted())
                .monospacedDigit()
        }
    }

    private var detail: String {
        let count = total.count == 1 ? "1 Buchung" : "\(total.count) Buchungen"
        return "\(count) · \(total.share.formatted(.percent.precision(.fractionLength(0))))"
    }
}

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: expense.category)
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .lineLimit(1)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(expense.amount.formatted())
                .monospacedDigit()
        }
    }

    private var subtitle: String {
        [expense.merchant, expense.category?.name]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}
