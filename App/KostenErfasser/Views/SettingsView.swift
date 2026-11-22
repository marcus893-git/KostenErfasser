import KostenErfasserCore
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query(sort: \Expense.date) private var expenses: [Expense]
    @Query(sort: \ExpenseCategory.sortOrder) private var categories: [ExpenseCategory]
    @State private var exportURL: URL?
    @State private var exportError: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("CSV-Export erstellen", systemImage: "tablecells", action: createExport)
                        .disabled(expenses.isEmpty)
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Label("Ausgaben.csv teilen oder sichern", systemImage: "square.and.arrow.up")
                        }
                    }
                    if let exportError {
                        Text(exportError)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Daten")
                } footer: {
                    Text("Die CSV-Datei lässt sich mit Excel oder Numbers öffnen und z. B. in der Dateien-App sichern.")
                }

                Section("Kategorien") {
                    ForEach(categories.filter(\.isTopLevel)) { category in
                        HStack(spacing: 12) {
                            CategoryIcon(category: category)
                            Text(category.name)
                            Spacer()
                            Text("\(categories.filter { $0.parentID == category.id }.count) Unterkategorien")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Info") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Gespeicherte Ausgaben", value: "\(expenses.count)")
                }
            }
            .navigationTitle("Einstellungen")
        }
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }

    private func createExport() {
        let byID = Dictionary(categories.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let rows = expenses.map { expense in
            let category = expense.category
            let parent = category?.parentID.flatMap { byID[$0] }
            return CSVExportRow(
                date: expense.date,
                amount: expense.amount,
                title: expense.title,
                merchant: expense.merchant,
                category: parent?.name ?? category?.name,
                subcategory: parent == nil ? nil : category?.name,
                paymentMethod: expense.paymentMethod,
                note: expense.note)
        }
        let url = URL.temporaryDirectory.appending(path: "Ausgaben.csv")
        do {
            try CSVExporter.data(rows, calendar: Calendar.kostenErfasser()).write(to: url, options: .atomic)
            exportURL = url
            exportError = nil
        } catch {
            exportURL = nil
            exportError = "Export fehlgeschlagen: \(error.localizedDescription)"
        }
    }
}
