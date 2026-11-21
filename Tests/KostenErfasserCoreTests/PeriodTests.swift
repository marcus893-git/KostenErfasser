import Foundation
import Testing

@testable import KostenErfasserCore

struct PeriodTests {
    let calendar = Calendar.kostenErfasser(timeZone: TimeZone(identifier: "Europe/Berlin")!)

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    private func midnight(_ year: Int, _ month: Int, _ day: Int) -> Date {
        date(year, month, day, hour: 0)
    }

    @Test func calendarUsesGermanWeeks() {
        #expect(calendar.firstWeekday == 2)
        #expect(calendar.minimumDaysInFirstWeek == 4)
    }

    @Test func month() {
        let period = Period.containing(date(2026, 11, 21), kind: .month, calendar: calendar)
        #expect(period.start == midnight(2026, 11, 1))
        #expect(period.end == midnight(2026, 12, 1))
        #expect(period.dayCount(calendar: calendar) == 30)
    }

    @Test func weekStartsOnMonday() {
        // 21.11.2026 is a Saturday.
        let period = Period.containing(date(2026, 11, 21), kind: .week, calendar: calendar)
        #expect(period.start == midnight(2026, 11, 16))
        #expect(period.end == midnight(2026, 11, 23))
    }

    @Test func quarter() {
        let autumn = Period.containing(date(2026, 11, 21), kind: .quarter, calendar: calendar)
        #expect(autumn.start == midnight(2026, 10, 1))
        #expect(autumn.end == midnight(2027, 1, 1))

        let winter = Period.containing(date(2026, 2, 14), kind: .quarter, calendar: calendar)
        #expect(winter.start == midnight(2026, 1, 1))
        #expect(winter.end == midnight(2026, 4, 1))
    }

    @Test func year() {
        let period = Period.containing(date(2026, 7, 1), kind: .year, calendar: calendar)
        #expect(period.start == midnight(2026, 1, 1))
        #expect(period.end == midnight(2027, 1, 1))
    }

    @Test func endIsExclusive() {
        let period = Period.containing(date(2026, 11, 21), kind: .month, calendar: calendar)
        #expect(period.contains(midnight(2026, 11, 1)))
        #expect(period.contains(date(2026, 11, 30, hour: 23, minute: 59)))
        #expect(!period.contains(midnight(2026, 12, 1)))
    }

    @Test func previousPeriods() {
        let november = Period.containing(date(2026, 11, 21), kind: .month, calendar: calendar)
        #expect(november.previous(calendar: calendar).start == midnight(2026, 10, 1))

        let january = Period.containing(date(2026, 1, 15), kind: .month, calendar: calendar)
        let december = january.previous(calendar: calendar)
        #expect(december.start == midnight(2025, 12, 1))
        #expect(december.end == midnight(2026, 1, 1))

        let week = Period.containing(date(2026, 11, 21), kind: .week, calendar: calendar)
        #expect(week.previous(calendar: calendar).start == midnight(2026, 11, 9))
    }

    @Test func sameRangeLastYear() {
        let november = Period.containing(date(2026, 11, 21), kind: .month, calendar: calendar)
        let lastYear = november.sameRangeLastYear(calendar: calendar)
        #expect(lastYear.start == midnight(2025, 11, 1))
        #expect(lastYear.end == midnight(2025, 12, 1))

        let week = Period.containing(date(2026, 11, 16), kind: .week, calendar: calendar)
        let lastYearWeek = week.sameRangeLastYear(calendar: calendar)
        #expect(lastYearWeek.kind == .week)
        #expect(lastYearWeek.contains(date(2025, 11, 16)))
        #expect(calendar.component(.weekday, from: lastYearWeek.start) == 2)
        #expect(lastYearWeek.dayCount(calendar: calendar) == 7)
    }

    @Test func leapYears() {
        #expect(
            Period.containing(date(2028, 2, 10), kind: .month, calendar: calendar).dayCount(calendar: calendar) == 29)
        #expect(
            Period.containing(date(2027, 2, 10), kind: .month, calendar: calendar).dayCount(calendar: calendar) == 28)
        #expect(
            Period.containing(date(2028, 6, 1), kind: .year, calendar: calendar).dayCount(calendar: calendar) == 366)
    }

    @Test func daylightSavingTimeChange() {
        // Clocks go forward on 29.03.2026 in Germany: the month is one hour shorter but still 31 days.
        let march = Period.containing(date(2026, 3, 15), kind: .month, calendar: calendar)
        #expect(march.dayCount(calendar: calendar) == 31)
        #expect(march.end.timeIntervalSince(march.start) == 31 * 24 * 3600 - 3600)
    }

    @Test func customRangeCoversWholeDays() {
        let period = Period.custom(from: date(2026, 11, 20), through: date(2026, 11, 10), calendar: calendar)
        #expect(period.kind == nil)
        #expect(period.start == midnight(2026, 11, 10))
        #expect(period.end == midnight(2026, 11, 21))
        #expect(period.dayCount(calendar: calendar) == 11)

        let previous = period.previous(calendar: calendar)
        #expect(previous.start == midnight(2026, 10, 30))
        #expect(previous.end == period.start)
    }
}
