import Foundation
import SwiftData

/// A category or subcategory. Subcategories point to their parent via `parentID`.
/// Categories are archived instead of deleted, so old statistics stay correct.
@Model
final class ExpenseCategory {
    var id: UUID = UUID()
    var name: String = ""
    var symbolName: String = "tag"
    var colorHex: String = "#757575"
    var sortOrder: Int = 0
    var isArchived: Bool = false
    /// `nil` for top-level categories.
    var parentID: UUID?

    @Relationship(deleteRule: .nullify, inverse: \Expense.category)
    var expenses: [Expense] = []

    init(name: String, symbolName: String, colorHex: String, sortOrder: Int, parentID: UUID? = nil) {
        self.name = name
        self.symbolName = symbolName
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.parentID = parentID
    }

    var isTopLevel: Bool { parentID == nil }

    /// The ID used for statistics: the parent for subcategories, otherwise the category itself.
    var topLevelID: UUID { parentID ?? id }
}
