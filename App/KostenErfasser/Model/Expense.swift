import Foundation
import KostenErfasserCore
import SwiftData

@Model
final class Expense {
    var id: UUID = UUID()
    /// Gross amount in cents; see `Money`.
    var amountCents: Int64 = 0
    var currency: String = "EUR"
    var date: Date = Date()
    var title: String = ""
    var merchant: String?
    var note: String?
    var paymentMethodRaw: String?
    var sourceRaw: String = "manuell"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var category: ExpenseCategory?

    init(
        amount: Money,
        date: Date,
        title: String,
        merchant: String?,
        note: String?,
        paymentMethod: PaymentMethod?,
        category: ExpenseCategory?,
        source: ExpenseSource = .manuell
    ) {
        self.amountCents = amount.cents
        self.currency = amount.currency
        self.date = date
        self.title = title
        self.merchant = merchant
        self.note = note
        self.paymentMethodRaw = paymentMethod?.rawValue
        self.category = category
        self.sourceRaw = source.rawValue
    }

    var amount: Money {
        get { Money(cents: amountCents, currency: currency) }
        set {
            amountCents = newValue.cents
            currency = newValue.currency
        }
    }

    var paymentMethod: PaymentMethod? {
        get { paymentMethodRaw.flatMap(PaymentMethod.init(rawValue:)) }
        set { paymentMethodRaw = newValue?.rawValue }
    }

    /// Snapshot for the statistics engine, aggregated by top-level category.
    var record: ExpenseRecord {
        ExpenseRecord(
            id: id, amount: amount, date: date, categoryID: category?.topLevelID, merchant: merchant,
            paymentMethod: paymentMethod)
    }
}
