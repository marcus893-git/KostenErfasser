import Foundation
import KostenErfasserCore
import SwiftData

/// Creates the default categories on first launch.
enum CategorySeeder {
    static func seedIfNeeded(_ context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<ExpenseCategory>())) ?? 0
        guard existing == 0 else { return }

        for (index, template) in DefaultCategories.all.enumerated() {
            let parent = ExpenseCategory(
                name: template.name, symbolName: template.symbolName, colorHex: template.colorHex,
                sortOrder: index * 100)
            context.insert(parent)
            for (subIndex, name) in template.subcategories.enumerated() {
                let child = ExpenseCategory(
                    name: name, symbolName: template.symbolName, colorHex: template.colorHex,
                    sortOrder: index * 100 + subIndex + 1, parentID: parent.id)
                context.insert(child)
            }
        }
        try? context.save()
    }
}
