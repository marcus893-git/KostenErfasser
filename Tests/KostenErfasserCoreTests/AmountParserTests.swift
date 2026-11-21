import Testing

@testable import KostenErfasserCore

struct AmountParserTests {
    // MARK: Manual input

    @Test(
        arguments: [
            ("12", 1_200),
            ("12,5", 1_250),
            ("12,50", 1_250),
            ("12.50", 1_250),
            ("0,99", 99),
            (",50", 50),
            ("12,", 1_200),
            ("12,-", 1_200),
            ("1.234", 123_400),
            ("1.234,56", 123_456),
            ("1,234.56", 123_456),
            ("1.234.567,89", 123_456_789),
            ("12,34 €", 1_234),
            ("EUR 12,34", 1_234),
            ("  7,00  ", 700),
            ("-3,50", -350),
            ("3,50-", -350),
            ("\u{2212}3,50", -350),
        ] as [(String, Int64)])
    func parsesManualInput(text: String, cents: Int64) {
        #expect(AmountParser.parseCents(text) == cents)
    }

    @Test(arguments: [
        "", "abc", "12,345,6", "1.2.3", "1,234.567", "12.3456", "1234567890123", "--5", "12 34 x",
    ])
    func rejectsInvalidInput(text: String) {
        #expect(AmountParser.parseCents(text) == nil)
    }

    // MARK: Receipt lines

    @Test(
        arguments: [
            ("SUMME EUR 23,45", [2_345]),
            ("Gesamtbetrag 1.234,56 EUR", [123_456]),
            ("2 x 1,99 3,98 A", [199, 398]),
            ("MwSt 19% 3,75", [375]),
            ("Rabatt 1,50-", [-150]),
            ("Pfand -0,25", [-25]),
            ("Summe 12,34.", [1_234]),
            ("EUR23,45", [2_345]),
            ("Datum 21.11.2026 14:32", []),
            ("21.11.26", []),
            ("Artikel 4006381333931", []),
            ("Tel. 0221 12345", []),
            ("Preis 12,-", []),
        ] as [(String, [Int64])])
    func findsAmountsInLine(line: String, cents: [Int64]) {
        #expect(AmountParser.amounts(in: line).map(\.cents) == cents)
    }

    @Test func matchRangeIncludesSign() throws {
        let line = "Rabatt 1,50-"
        let match = try #require(AmountParser.amounts(in: line).first)
        #expect(line[match.range] == "1,50-")
    }
}
