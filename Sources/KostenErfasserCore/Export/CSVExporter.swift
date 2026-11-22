import Foundation

/// One line of the CSV export.
public struct CSVExportRow: Hashable, Sendable {
    public let date: Date
    public let amount: Money
    public let title: String
    public let merchant: String?
    public let category: String?
    public let subcategory: String?
    public let paymentMethod: PaymentMethod?
    public let note: String?

    public init(
        date: Date,
        amount: Money,
        title: String,
        merchant: String? = nil,
        category: String? = nil,
        subcategory: String? = nil,
        paymentMethod: PaymentMethod? = nil,
        note: String? = nil
    ) {
        self.date = date
        self.amount = amount
        self.title = title
        self.merchant = merchant
        self.category = category
        self.subcategory = subcategory
        self.paymentMethod = paymentMethod
        self.note = note
    }
}

/// Writes expenses as CSV that German Excel and Numbers open directly:
/// semicolon separator, decimal comma, dates as TT.MM.JJJJ, CRLF line endings, UTF-8 with BOM.
public enum CSVExporter {
    public static let header = [
        "Datum", "Betrag", "Währung", "Beschreibung", "Händler", "Kategorie", "Unterkategorie", "Zahlungsart", "Notiz",
    ]

    /// CSV text without byte order mark.
    public static func csv(_ rows: [CSVExportRow], calendar: Calendar) -> String {
        var lines = [header.map(escape).joined(separator: ";")]
        for row in rows {
            let fields = [
                formatDate(row.date, calendar: calendar),
                formatAmount(row.amount),
                row.amount.currency,
                row.title,
                row.merchant ?? "",
                row.category ?? "",
                row.subcategory ?? "",
                row.paymentMethod?.displayName ?? "",
                row.note ?? "",
            ]
            lines.append(fields.map(escape).joined(separator: ";"))
        }
        return lines.joined(separator: "\r\n") + "\r\n"
    }

    /// UTF-8 data with byte order mark, so Excel on Windows shows umlauts correctly.
    public static func data(_ rows: [CSVExportRow], calendar: Calendar) -> Data {
        Data(("\u{FEFF}" + csv(rows, calendar: calendar)).utf8)
    }

    static func formatDate(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%02d.%02d.%04d", parts.day ?? 0, parts.month ?? 0, parts.year ?? 0)
    }

    /// "1234,56" without thousands separators, so spreadsheets read it as a number.
    static func formatAmount(_ money: Money) -> String {
        AmountInputFormatter.text(for: money)
    }

    static func escape(_ field: String) -> String {
        guard field.contains(where: { $0 == ";" || $0 == "\"" || $0 == "\n" || $0 == "\r" }) else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
