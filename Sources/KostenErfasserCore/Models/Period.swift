import Foundation

/// The kind of a reporting period in the statistics screen.
public enum PeriodKind: String, Sendable, Codable, CaseIterable {
    case week
    case month
    case quarter
    case year
}

/// A half-open time range `[start, end)` used for statistics and comparisons.
public struct Period: Hashable, Sendable {
    /// `nil` for a custom range chosen by the user.
    public let kind: PeriodKind?
    /// Inclusive start.
    public let start: Date
    /// Exclusive end.
    public let end: Date

    public init(kind: PeriodKind?, start: Date, end: Date) {
        precondition(start <= end, "Period start must not be after its end")
        self.kind = kind
        self.start = start
        self.end = end
    }

    /// The week, month, quarter or year that contains `date`.
    public static func containing(_ date: Date, kind: PeriodKind, calendar: Calendar) -> Period {
        let start: Date
        let length: DateComponents
        switch kind {
        case .week:
            start = calendar.dateInterval(of: .weekOfYear, for: date)!.start
            length = DateComponents(day: 7)
        case .month:
            start = calendar.dateInterval(of: .month, for: date)!.start
            length = DateComponents(month: 1)
        case .quarter:
            // Computed by hand: Calendar's .quarter support differs between platforms.
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let firstMonth = (month - 1) / 3 * 3 + 1
            start = calendar.date(from: DateComponents(year: year, month: firstMonth, day: 1))!
            length = DateComponents(month: 3)
        case .year:
            start = calendar.dateInterval(of: .year, for: date)!.start
            length = DateComponents(year: 1)
        }
        let end = calendar.date(byAdding: length, to: start)!
        return Period(kind: kind, start: start, end: end)
    }

    /// A custom range covering whole days from `firstDay` through `lastDay`.
    public static func custom(from firstDay: Date, through lastDay: Date, calendar: Calendar) -> Period {
        let start = calendar.startOfDay(for: min(firstDay, lastDay))
        let lastStart = calendar.startOfDay(for: max(firstDay, lastDay))
        let end = calendar.date(byAdding: .day, value: 1, to: lastStart)!
        return Period(kind: nil, start: start, end: end)
    }

    public func contains(_ date: Date) -> Bool {
        start <= date && date < end
    }

    /// Number of calendar days in the period.
    public func dayCount(calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// The period directly before this one, e.g. the previous month.
    /// For a custom range: the same number of days directly before it.
    public func previous(calendar: Calendar) -> Period {
        guard let kind else {
            let days = dayCount(calendar: calendar)
            let newStart = calendar.date(byAdding: .day, value: -days, to: start)!
            return Period(kind: nil, start: newStart, end: start)
        }
        let dayBefore = calendar.date(byAdding: .day, value: -1, to: start)!
        return Period.containing(dayBefore, kind: kind, calendar: calendar)
    }

    /// The same period one year earlier, e.g. November 2025 for November 2026.
    public func sameRangeLastYear(calendar: Calendar) -> Period {
        let shiftedStart = calendar.date(byAdding: .year, value: -1, to: start)!
        guard let kind else {
            let shiftedEnd = calendar.date(byAdding: .year, value: -1, to: end)!
            return Period(kind: nil, start: shiftedStart, end: shiftedEnd)
        }
        return Period.containing(shiftedStart, kind: kind, calendar: calendar)
    }
}

extension Calendar {
    /// Gregorian calendar with German conventions: weeks start on Monday (ISO 8601 weeks).
    public static func kostenErfasser(timeZone: TimeZone = .current) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "de_DE")
        calendar.timeZone = timeZone
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }
}
