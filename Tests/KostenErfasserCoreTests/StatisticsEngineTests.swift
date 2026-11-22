import Foundation
import Testing

@testable import KostenErfasserCore

struct StatisticsEngineTests {
    let calendar = Calendar.kostenErfasser(timeZone: TimeZone(identifier: "Europe/Berlin")!)
    let food = UUID()
    let mobility = UUID()

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func record(_ cents: Int64, _ year: Int, _ month: Int, _ day: Int, _ category: UUID?) -> ExpenseRecord {
        ExpenseRecord(amount: Money(cents: cents), date: date(year, month, day), categoryID: category)
    }

    private var sample: [ExpenseRecord] {
        [
            record(2_345, 2026, 11, 3, food),
            record(1_000, 2026, 11, 20, food),
            record(5_000, 2026, 11, 21, mobility),
            record(999, 2026, 11, 21, nil),
            record(4_000, 2026, 10, 5, food),
            record(700, 2026, 10, 25, mobility),
            record(1_500, 2025, 11, 10, food),
        ]
    }

    @Test func totalOfMonth() {
        let november = Period.containing(date(2026, 11, 21), kind: .month, calendar: calendar)
        #expect(StatisticsEngine.total(sample, in: november) == Money(cents: 9_344))
        #expect(StatisticsEngine.records(sample, in: november).count == 4)
    }

    @Test func totalsByCategoryAreSortedWithShares() throws {
        let november = Period.containing(date(2026, 11, 21), kind: .month, calendar: calendar)
        let totals = StatisticsEngine.totalsByCategory(sample, in: november)
        #expect(totals.map(\.categoryID) == [mobility, food, nil])
        #expect(totals.map(\.amount.cents) == [5_000, 3_345, 999])
        #expect(totals.map(\.count) == [1, 2, 1])
        let shareSum = totals.map(\.share).reduce(0, +)
        #expect(abs(shareSum - 1) < 1e-9)
        let first = try #require(totals.first)
        #expect(abs(first.share - 5_000.0 / 9_344.0) < 1e-9)
    }

    @Test func emptyPeriodHasNoCategories() {
        let june = Period.containing(date(2026, 6, 1), kind: .month, calendar: calendar)
        #expect(StatisticsEngine.totalsByCategory(sample, in: june).isEmpty)
        #expect(StatisticsEngine.total(sample, in: june) == .zero())
    }

    @Test func monthlySeriesOldestFirst() {
        let series = StatisticsEngine.series(
            sample, kind: .month, count: 13, endingWith: date(2026, 11, 21), calendar: calendar)
        #expect(series.count == 13)
        #expect(series.first?.period.start == date(2025, 11, 1, hour: 0))
        #expect(series.last?.period.start == date(2026, 11, 1, hour: 0))
        #expect(series.first?.amount == Money(cents: 1_500))
        #expect(series[11].amount == Money(cents: 4_700))
        #expect(series.last?.amount == Money(cents: 9_344))
        #expect(series.last?.count == 4)
        #expect(StatisticsEngine.series(sample, kind: .month, count: 0, endingWith: .now, calendar: calendar).isEmpty)
    }

    @Test func monthToDateComparesSameDays() throws {
        // 21.11.: November 1-21 against October 1-21.
        let comparison = StatisticsEngine.monthToDate(sample, now: date(2026, 11, 21, hour: 9), calendar: calendar)
        #expect(comparison.current == Money(cents: 9_344))
        #expect(comparison.previous == Money(cents: 4_000))
        let change = try #require(comparison.changeRatio)
        #expect(abs(change - 1.336) < 1e-9)
    }

    @Test func monthToDateClampsToShorterPreviousMonth() {
        let records = [record(100, 2026, 2, 28, food), record(200, 2026, 3, 31, food)]
        let comparison = StatisticsEngine.monthToDate(records, now: date(2026, 3, 31), calendar: calendar)
        #expect(comparison.current == Money(cents: 200))
        #expect(comparison.previous == Money(cents: 100))
    }

    @Test func changeRatioIsNilWithoutPreviousSpending() {
        #expect(MonthToDateComparison(current: Money(cents: 500), previous: .zero()).changeRatio == nil)
    }
}
