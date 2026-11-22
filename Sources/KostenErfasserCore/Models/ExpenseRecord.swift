import Foundation

/// A plain snapshot of an expense for statistics.
///
/// The app maps its SwiftData models to this type, so all calculations
/// stay independent of SwiftData and can be tested on Linux.
public struct ExpenseRecord: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let amount: Money
    public let date: Date
    /// Top-level category used for aggregation; `nil` if the expense has none.
    public let categoryID: UUID?
    public let merchant: String?
    public let paymentMethod: PaymentMethod?

    public init(
        id: UUID = UUID(),
        amount: Money,
        date: Date,
        categoryID: UUID?,
        merchant: String? = nil,
        paymentMethod: PaymentMethod? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.categoryID = categoryID
        self.merchant = merchant
        self.paymentMethod = paymentMethod
    }
}
