import Foundation
import Testing

@testable import KostenErfasserCore

struct CSVExporterTests {
    let calendar = Calendar.kostenErfasser(timeZone: TimeZone(identifier: "Europe/Berlin")!)

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    @Test func writesHeaderAndRows() {
        let rows = [
            CSVExportRow(
                date: date(2026, 11, 3), amount: Money(cents: 2_345), title: "Wocheneinkauf", merchant: "REWE",
                category: "Lebensmittel", subcategory: "Supermarkt", paymentMethod: .girocard),
            CSVExportRow(date: date(2026, 1, 9), amount: Money(cents: -150), title: "Pfand"),
        ]
        let lines = CSVExporter.csv(rows, calendar: calendar).components(separatedBy: "\r\n")
        #expect(lines[0] == "Datum;Betrag;Währung;Beschreibung;Händler;Kategorie;Unterkategorie;Zahlungsart;Notiz")
        #expect(lines[1] == "03.11.2026;23,45;EUR;Wocheneinkauf;REWE;Lebensmittel;Supermarkt;Girocard;")
        #expect(lines[2] == "09.01.2026;-1,50;EUR;Pfand;;;;;")
        #expect(lines[3] == "")
        #expect(lines.count == 4)
    }

    @Test func formatsAmountsWithoutThousandsSeparator() {
        #expect(CSVExporter.formatAmount(Money(cents: 123_456)) == "1234,56")
        #expect(CSVExporter.formatAmount(Money(cents: 5)) == "0,05")
        #expect(CSVExporter.formatAmount(Money(cents: -100)) == "-1,00")
    }

    @Test func escapesSpecialCharacters() {
        #expect(CSVExporter.escape("ohne Sonderzeichen") == "ohne Sonderzeichen")
        #expect(CSVExporter.escape("Brot; Milch") == "\"Brot; Milch\"")
        #expect(CSVExporter.escape("Zoll \"12\"") == "\"Zoll \"\"12\"\"\"")
        #expect(CSVExporter.escape("Zeile 1\nZeile 2") == "\"Zeile 1\nZeile 2\"")
    }

    @Test func dataStartsWithByteOrderMark() {
        let data = CSVExporter.data([], calendar: calendar)
        #expect(Array(data.prefix(3)) == [0xEF, 0xBB, 0xBF])
    }
}
