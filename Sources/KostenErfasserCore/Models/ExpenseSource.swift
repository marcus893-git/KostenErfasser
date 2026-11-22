/// How an expense was created. Raw values are stored, so they must never change.
public enum ExpenseSource: String, Sendable, Codable, CaseIterable {
    case manuell
    case scan
    case imported = "import"
    case wiederkehrend
}
