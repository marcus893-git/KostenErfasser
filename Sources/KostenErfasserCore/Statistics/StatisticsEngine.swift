import Foundation

/// Sum of one category within a period.
public struct CategoryTotal: Hashable, Sendable {
    /// `nil` collects expenses without a category.
    public let categoryID: UUID?
    public let amount: Money
    public let count: Int
    /// Share of the period total from 0 to 1 (for display only). Zero if the total is not positive.
    public let share: Double
}

/// Sum of one period in a time series.
public struct PeriodTotal: Hashable, Sendable {
    public let period: Period
    public let amount: Money
    public let count: Int
}

/// Spending in the current month so far compared with the previous month up to the same day.
public struct MonthToDateComparison: Hashable, Sendable {
    public let current: Money
    public let previous: Money

    /// Relative change, e.g. 0.25 for +25 %. `nil` if the previous amount is zero.
    public var changeRatio: Double? {
        guard previous.cents != 0 else { return nil }
        return Double(current.cents - previous.cents) / Double(abs(previous.cents))
    }
}

/// Aggregations for the overview and statistics screens. All amounts are in EUR.
public enum StatisticsEngine {
    public static func records(_ records: [ExpenseRecord], in period: Period) -> [ExpenseRecord] {
        records.filter { period.contains($0.date) }
    }

    public static func total(_ records: [ExpenseRecord], in period: Period) -> Money {
        Self.records(records, in: period).map(\.amount).sum()
    }

    /// Totals per category, largest first. Ties are ordered by number of expenses.
    public static func totalsByCategory(_ records: [ExpenseRecord], in period: Period) -> [CategoryTotal] {
        let inPeriod = Self.records(records, in: period)
        let periodTotal = inPeriod.map(\.amount).sum()
        let grouped = Dictionary(grouping: inPeriod, by: \.categoryID)
        return grouped.map { categoryID, items in
            let amount = items.map(\.amount).sum()
            let share = periodTotal.cents > 0 ? Double(amount.cents) / Double(periodTotal.cents) : 0
            return CategoryTotal(categoryID: categoryID, amount: amount, count: items.count, share: share)
        }
        .sorted { lhs, rhs in
            lhs.amount.cents != rhs.amount.cents ? lhs.amount.cents > rhs.amount.cents : lhs.count > rhs.count
        }
    }

    /// The last `count` periods of `kind` up to and including the one containing `date`, oldest first.
    public static func series(
        _ records: [ExpenseRecord],
        kind: PeriodKind,
        count: Int,
        endingWith date: Date,
        calendar: Calendar
    ) -> [PeriodTotal] {
        guard count > 0 else { return [] }
        var periods = [Period.containing(date, kind: kind, calendar: calendar)]
        while periods.count < count {
            periods.insert(periods[0].previous(calendar: calendar), at: 0)
        }
        return periods.map { period in
            let items = Self.records(records, in: period)
            return PeriodTotal(period: period, amount: items.map(\.amount).sum(), count: items.count)
        }
    }

    /// Current month from its first day through the day of `now`, compared with the previous
    /// month through the same day number (or its last day if that month is shorter).
    public static func monthToDate(_ records: [ExpenseRecord], now: Date, calendar: Calendar) -> MonthToDateComparison {
        let month = Period.containing(now, kind: .month, calendar: calendar)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let currentRange = Period(kind: nil, start: month.start, end: min(startOfTomorrow, month.end))

        let previousMonth = month.previous(calendar: calendar)
        let dayOfMonth = calendar.component(.day, from: now)
        let previousEnd = calendar.date(byAdding: .day, value: dayOfMonth, to: previousMonth.start)!
        let previousRange = Period(kind: nil, start: previousMonth.start, end: min(previousEnd, previousMonth.end))

        return MonthToDateComparison(
            current: total(records, in: currentRange),
            previous: total(records, in: previousRange)
        )
    }
}
