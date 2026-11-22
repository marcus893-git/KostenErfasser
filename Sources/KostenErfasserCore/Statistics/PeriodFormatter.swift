import Foundation

extension PeriodKind {
    /// German label for the period picker.
    public var displayName: String {
        switch self {
        case .week: "Woche"
        case .month: "Monat"
        case .quarter: "Quartal"
        case .year: "Jahr"
        }
    }
}

/// German titles for periods, e.g. "KW 47 · 16.11.–22.11.2026", "November 2026", "Q4 2026".
public enum PeriodFormatter {
    public static func title(for period: Period, calendar: Calendar) -> String {
        let year = calendar.component(.year, from: period.start)
        let lastDay = calendar.date(byAdding: .day, value: -1, to: period.end) ?? period.start
        switch period.kind {
        case .week:
            let week = calendar.component(.weekOfYear, from: period.start)
            return "KW \(week) · \(dayMonth(period.start, calendar))–\(fullDate(lastDay, calendar))"
        case .month:
            let month = calendar.component(.month, from: period.start)
            return "\(calendar.standaloneMonthSymbols[month - 1]) \(year)"
        case .quarter:
            let quarter = (calendar.component(.month, from: period.start) - 1) / 3 + 1
            return "Q\(quarter) \(year)"
        case .year:
            return "\(year)"
        case nil:
            return "\(fullDate(period.start, calendar)) – \(fullDate(lastDay, calendar))"
        }
    }

    private static func dayMonth(_ date: Date, _ calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.day, .month], from: date)
        return String(format: "%02d.%02d.", parts.day ?? 0, parts.month ?? 0)
    }

    private static func fullDate(_ date: Date, _ calendar: Calendar) -> String {
        let year = calendar.component(.year, from: date)
        return dayMonth(date, calendar) + String(year)
    }
}
