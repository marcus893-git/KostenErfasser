import Foundation

/// An amount found inside a line of text, e.g. on a receipt.
public struct AmountMatch: Hashable, Sendable {
    /// Amount in cents, negative if the text marks it as negative ("-1,50" or "1,50-").
    public let cents: Int64
    /// Position of the matched characters (including a sign) in the source string.
    public let range: Range<String.Index>
}

/// Parses money amounts in German and English notation.
///
/// Supported: "12,34", "1.234,56", "1234.56", "1,234.56", "12,34 €", "EUR 12,34",
/// "-3,50" and the receipt style "3,50-" for discounts.
public enum AmountParser {
    /// Maximum number of integer digits; protects against overflow and OCR garbage.
    static let maxIntegerDigits = 12

    // MARK: Manual input

    /// Parses a single amount typed by the user. Lenient: allows 0 to 2 decimals,
    /// so "12", "12,5" and "1.234" are valid. Returns nil for anything else.
    public static func parseCents(_ text: String) -> Int64? {
        var token = text.trimmingCharacters(in: .whitespacesAndNewlines)
        for currencyMarker in ["€", "EUR", "eur", "Eur"] {
            token = token.replacingOccurrences(of: currencyMarker, with: "")
        }
        token = token.filter { !$0.isWhitespace }
        // German price notation "12,-" means 12 euros, not a negative amount.
        if token.hasSuffix(",-") || token.hasSuffix(".-") {
            token.removeLast(2)
        }

        var negative = false
        if let first = token.first, minusSigns.contains(first) {
            negative = true
            token.removeFirst()
        } else if let last = token.last, minusSigns.contains(last) {
            negative = true
            token.removeLast()
        }
        // "12," while typing means 12.
        while let last = token.last, separators.contains(last) {
            token.removeLast()
        }

        guard let cents = centsFromNumber(token, requireTwoDecimals: false) else { return nil }
        return negative ? -cents : cents
    }

    // MARK: Text scanning

    /// Finds all amounts with exactly two decimals in a line of text.
    ///
    /// Number-like tokens that are not amounts, such as dates ("21.11.2026"),
    /// times or article numbers, are ignored.
    public static func amounts(in line: String) -> [AmountMatch] {
        var matches: [AmountMatch] = []
        var index = line.startIndex

        while index < line.endIndex {
            guard line[index].isASCIIDigit else {
                index = line.index(after: index)
                continue
            }

            // Maximal run of digits and separators.
            var end = index
            while end < line.endIndex, line[end].isASCIIDigit || separators.contains(line[end]) {
                end = line.index(after: end)
            }
            // A trailing separator belongs to the sentence, not to the number ("Summe 12,34.").
            var numberEnd = end
            while numberEnd > index, separators.contains(line[line.index(before: numberEnd)]) {
                numberEnd = line.index(before: numberEnd)
            }

            if let cents = centsFromNumber(String(line[index..<numberEnd]), requireTwoDecimals: true) {
                var start = index
                var stop = numberEnd
                var negative = false
                if start > line.startIndex, minusSigns.contains(line[line.index(before: start)]) {
                    negative = true
                    start = line.index(before: start)
                } else if stop < line.endIndex, minusSigns.contains(line[stop]) {
                    negative = true
                    stop = line.index(after: stop)
                }
                matches.append(AmountMatch(cents: negative ? -cents : cents, range: start..<stop))
            }
            index = end
        }
        return matches
    }

    // MARK: Number grammar

    private static let separators: Set<Character> = [".", ","]
    private static let minusSigns: Set<Character> = ["-", "\u{2212}"]

    /// Converts a token consisting of digits, "." and "," into cents.
    ///
    /// The last separator is the decimal separator if it is followed by one or two digits
    /// (exactly two if `requireTwoDecimals`). All other separators must be the other
    /// character and split the integer part into groups of three digits.
    static func centsFromNumber(_ token: String, requireTwoDecimals: Bool) -> Int64? {
        guard !token.isEmpty, token.allSatisfy({ $0.isASCIIDigit || separators.contains($0) }) else {
            return nil
        }

        var integerPart = token
        var fractionPart = ""
        var decimalSeparator: Character?

        if let lastSeparatorIndex = token.lastIndex(where: { separators.contains($0) }) {
            let digitsAfter = token[token.index(after: lastSeparatorIndex)...]
            let separator = token[lastSeparatorIndex]
            let separatorCount = token.filter { $0 == separator }.count
            // "1.234" and "1.234.567" are thousands, "12,5" and "1.234,50" have decimals.
            let allowedDecimals = requireTwoDecimals ? 2...2 : 1...2
            let isDecimal = allowedDecimals.contains(digitsAfter.count) && separatorCount == 1
            if isDecimal {
                decimalSeparator = separator
                integerPart = String(token[..<lastSeparatorIndex])
                fractionPart = String(digitsAfter)
            } else if requireTwoDecimals {
                return nil
            }
        } else if requireTwoDecimals {
            return nil
        }

        guard let integerDigits = digitsOfIntegerPart(integerPart, decimalSeparator: decimalSeparator),
            !integerDigits.isEmpty || !fractionPart.isEmpty,
            integerDigits.count <= maxIntegerDigits
        else { return nil }

        let euros = Int64(integerDigits.isEmpty ? "0" : integerDigits) ?? 0
        let paddedFraction = fractionPart.padding(toLength: 2, withPad: "0", startingAt: 0)
        guard let fraction = Int64(paddedFraction) else { return nil }
        return euros * 100 + fraction
    }

    /// Validates thousands grouping and returns the plain digits of the integer part.
    private static func digitsOfIntegerPart(_ part: String, decimalSeparator: Character?) -> String? {
        let groupSeparators = Set(part.filter { separators.contains($0) })
        if groupSeparators.isEmpty { return part }
        guard groupSeparators.count == 1, let groupSeparator = groupSeparators.first,
            groupSeparator != decimalSeparator
        else { return nil }

        let groups = part.split(separator: groupSeparator, omittingEmptySubsequences: false)
        guard let first = groups.first, (1...3).contains(first.count),
            groups.dropFirst().allSatisfy({ $0.count == 3 })
        else { return nil }
        return groups.joined()
    }
}

extension Character {
    fileprivate var isASCIIDigit: Bool { ("0"..."9").contains(self) }
}
