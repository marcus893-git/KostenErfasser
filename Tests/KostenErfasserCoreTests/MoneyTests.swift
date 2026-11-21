import Foundation
import Testing

@testable import KostenErfasserCore

struct MoneyTests {
    /// Normalizes the non-breaking spaces that number formatters insert.
    private func plain(_ text: String) -> String {
        text.replacingOccurrences(of: "\u{00A0}", with: " ").replacingOccurrences(of: "\u{202F}", with: " ")
    }

    @Test func sumIsExact() {
        let amounts = [Money(cents: 10), Money(cents: 20), Money(cents: 1_999)]
        #expect(amounts.sum() == Money(cents: 2_029))
        #expect(amounts.sum().decimalValue == Decimal(string: "20.29"))
    }

    @Test func emptySumIsZero() {
        #expect([Money]().sum() == .zero())
    }

    @Test func arithmetic() {
        var total = Money(cents: 500)
        total += Money(cents: 250)
        #expect(total == Money(cents: 750))
        #expect(total - Money(cents: 1_000) == Money(cents: -250))
        #expect((-total).isNegative)
        #expect(Money(cents: 1) < Money(cents: 2))
    }

    @Test func formatsGermanCurrency() {
        #expect(plain(Money(cents: 123_456).formatted()) == "1.234,56 €")
        #expect(plain(Money(cents: 5).formatted()) == "0,05 €")
        #expect(plain(Money(cents: -1_234).formatted()) == "-12,34 €")
    }

    @Test func codableRoundTrip() throws {
        let original = Money(cents: 4_299, currency: "EUR")
        let data = try JSONEncoder().encode(original)
        #expect(try JSONDecoder().decode(Money.self, from: data) == original)
    }
}
