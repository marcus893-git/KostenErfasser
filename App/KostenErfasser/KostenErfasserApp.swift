import SwiftData
import SwiftUI

@main
struct KostenErfasserApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Expense.self, ExpenseCategory.self])
    }
}
