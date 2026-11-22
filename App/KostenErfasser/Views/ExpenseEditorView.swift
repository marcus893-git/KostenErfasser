import KostenErfasserCore
import SwiftData
import SwiftUI

/// Form for a new expense (`expense == nil`) or for editing an existing one.
struct ExpenseEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExpenseCategory.sortOrder) private var categories: [ExpenseCategory]

    let expense: Expense?
    var onSaved: () -> Void = {}

    @State private var amountText = ""
    @State private var title = ""
    @State private var merchant = ""
    @State private var date = Date.now
    @State private var categoryID: UUID?
    @State private var paymentMethod: PaymentMethod?
    @State private var note = ""
    @State private var didLoad = false

    private var parsedCents: Int64? { AmountParser.parseCents(amountText) }

    private var canSave: Bool {
        guard let cents = parsedCents else { return false }
        return cents != 0 && categoryID != nil
    }

    private var activeCategories: [ExpenseCategory] { categories.filter { !$0.isArchived } }
    private var topLevelCategories: [ExpenseCategory] { activeCategories.filter(\.isTopLevel) }

    private func children(of parent: ExpenseCategory) -> [ExpenseCategory] {
        activeCategories.filter { $0.parentID == parent.id }
    }

    var body: some View {
        Form {
            Section("Betrag") {
                TextField("0,00 €", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.largeTitle.monospacedDigit())
                if !amountText.isEmpty && parsedCents == nil {
                    Text("Bitte einen gültigen Betrag eingeben, z. B. 12,99.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            Section("Details") {
                TextField("Beschreibung", text: $title)
                TextField("Firma / Händler", text: $merchant)
                DatePicker("Datum", selection: $date, displayedComponents: .date)
            }
            Section("Kategorie") {
                Picker("Kategorie", selection: $categoryID) {
                    Text("Bitte wählen").tag(UUID?.none)
                    ForEach(topLevelCategories) { parent in
                        Text(parent.name).tag(UUID?.some(parent.id))
                        ForEach(children(of: parent)) { child in
                            Text("\(parent.name) › \(child.name)").tag(UUID?.some(child.id))
                        }
                    }
                }
                .pickerStyle(.navigationLink)
            }
            Section("Zahlung") {
                Picker("Zahlungsart", selection: $paymentMethod) {
                    Text("Keine Angabe").tag(PaymentMethod?.none)
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.displayName).tag(PaymentMethod?.some(method))
                    }
                }
            }
            Section("Notiz") {
                TextField("Notiz", text: $note, axis: .vertical)
            }
        }
        .navigationTitle(expense == nil ? "Ausgabe erfassen" : "Ausgabe bearbeiten")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern", action: save)
                    .disabled(!canSave)
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard !didLoad else { return }
        didLoad = true
        guard let expense else { return }
        amountText = AmountInputFormatter.text(for: expense.amount)
        title = expense.title
        merchant = expense.merchant ?? ""
        date = expense.date
        categoryID = expense.category?.id
        paymentMethod = expense.paymentMethod
        note = expense.note ?? ""
    }

    private func save() {
        guard let cents = parsedCents, let category = categories.first(where: { $0.id == categoryID }) else { return }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanMerchant = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = !cleanTitle.isEmpty ? cleanTitle : (!cleanMerchant.isEmpty ? cleanMerchant : category.name)

        if let expense {
            expense.amount = Money(cents: cents)
            expense.title = finalTitle
            expense.merchant = cleanMerchant.isEmpty ? nil : cleanMerchant
            expense.date = date
            expense.category = category
            expense.paymentMethod = paymentMethod
            expense.note = cleanNote.isEmpty ? nil : cleanNote
            expense.updatedAt = .now
        } else {
            let newExpense = Expense(
                amount: Money(cents: cents), date: date, title: finalTitle,
                merchant: cleanMerchant.isEmpty ? nil : cleanMerchant,
                note: cleanNote.isEmpty ? nil : cleanNote,
                paymentMethod: paymentMethod, category: category)
            modelContext.insert(newExpense)
        }
        try? modelContext.save()

        if expense == nil {
            resetForm()
            onSaved()
        } else {
            dismiss()
        }
    }

    private func resetForm() {
        amountText = ""
        title = ""
        merchant = ""
        date = .now
        categoryID = nil
        paymentMethod = nil
        note = ""
    }
}
