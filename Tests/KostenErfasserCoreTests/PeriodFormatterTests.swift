import Foundation
import Testing

@testable import KostenErfasserCore

struct PeriodFormatterTests {
    let calendar = Calendar.kostenErfasser(timeZone: TimeZone(identifier: "Europe/Berlin")!)

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func title(_ kind: PeriodKind, _ date: Date) -> String {
        PeriodFormatter.title(for: Period.containing(date, kind: kind, calendar: calendar), calendar: calendar)
    }

    @Test func titles() {
        #expect(title(.week, date(2026, 11, 21)) == "KW 47 · 16.11.–22.11.2026")
        #expect(title(.month, date(2026, 11, 21)) == "November 2026")
        #expect(title(.month, date(2026, 3, 1)) == "März 2026")
        #expect(title(.quarter, date(2026, 11, 21)) == "Q4 2026")
        #expect(title(.year, date(2026, 11, 21)) == "2026")
        let custom = Period.custom(from: date(2026, 11, 1), through: date(2026, 11, 15), calendar: calendar)
        #expect(PeriodFormatter.title(for: custom, calendar: calendar) == "01.11.2026 – 15.11.2026")
    }

    @Test func weekAcrossNewYear() {
        // 31.12.2026 is a Thursday and belongs to ISO week 53.
        #expect(title(.week, date(2026, 12, 31)) == "KW 53 · 28.12.–03.01.2027")
    }

    @Test func kindNames() {
        #expect(PeriodKind.allCases.map(\.displayName) == ["Woche", "Monat", "Quartal", "Jahr"])
    }
}
