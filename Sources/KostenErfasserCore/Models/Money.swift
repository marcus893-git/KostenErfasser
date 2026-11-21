import Foundation

/// A monetary amount stored as integer minor units (cents).
///
/// Amounts are never stored as floating point numbers, so sums are exact.
/// The app works with EUR only for now; `currency` is kept so that
/// foreign currencies can be added later without a data migration.
public struct Money: Hashable, Sendable, Codable {
    /// Amount in minor units (1/100 of the currency). Negative for refunds.
    public var cents: Int64
    /// ISO 4217 currency code, e.g. "EUR".
    public var currency: String

    public init(cents: Int64, currency: String = Money.defaultCurrency) {
        self.cents = cents
        self.currency = currency
    }

    public static let defaultCurrency = "EUR"

    public static func zero(currency: String = Money.defaultCurrency) -> Money {
        Money(cents: 0, currency: currency)
    }

    /// Exact decimal value, e.g. 1234 cents -> 12.34.
    public var decimalValue: Decimal {
        Decimal(cents) / 100
    }

    public var isNegative: Bool { cents < 0 }

    /// Localized currency string, e.g. "1.234,56 €" for de_DE.
    public func formatted(locale: Locale = Locale(identifier: "de_DE")) -> String {
        decimalValue.formatted(.currency(code: currency).locale(locale))
    }
}

extension Money: Comparable {
    public static func < (lhs: Money, rhs: Money) -> Bool {
        precondition(lhs.currency == rhs.currency, "Cannot compare \(lhs.currency) with \(rhs.currency)")
        return lhs.cents < rhs.cents
    }
}

extension Money {
    public static func + (lhs: Money, rhs: Money) -> Money {
        precondition(lhs.currency == rhs.currency, "Cannot add \(lhs.currency) and \(rhs.currency)")
        return Money(cents: lhs.cents + rhs.cents, currency: lhs.currency)
    }

    public static func - (lhs: Money, rhs: Money) -> Money {
        precondition(lhs.currency == rhs.currency, "Cannot subtract \(rhs.currency) from \(lhs.currency)")
        return Money(cents: lhs.cents - rhs.cents, currency: lhs.currency)
    }

    public static prefix func - (value: Money) -> Money {
        Money(cents: -value.cents, currency: value.currency)
    }

    public static func += (lhs: inout Money, rhs: Money) {
        lhs = lhs + rhs
    }
}

extension Sequence where Element == Money {
    /// Sum of all amounts. All elements must use `currency`.
    public func sum(currency: String = Money.defaultCurrency) -> Money {
        reduce(Money.zero(currency: currency), +)
    }
}
