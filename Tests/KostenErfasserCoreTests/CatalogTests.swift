import Testing

@testable import KostenErfasserCore

struct DefaultCategoriesTests {
    @Test func matchesConcept() {
        #expect(DefaultCategories.all.count == 15)
        #expect(DefaultCategories.all.first?.name == "Lebensmittel")
        #expect(DefaultCategories.all.last?.name == "Sonstiges")
    }

    @Test func namesAreUnique() {
        let names = DefaultCategories.all.map(\.name)
        #expect(Set(names).count == names.count)
        for category in DefaultCategories.all {
            #expect(Set(category.subcategories).count == category.subcategories.count, "\(category.name)")
        }
    }

    @Test func colorsAndSymbolsAreValid() {
        let hexDigits = Set("0123456789ABCDEF")
        for category in DefaultCategories.all {
            #expect(category.colorHex.count == 7 && category.colorHex.first == "#", "\(category.name)")
            #expect(category.colorHex.dropFirst().allSatisfy(hexDigits.contains), "\(category.name)")
            #expect(!category.symbolName.isEmpty, "\(category.name)")
        }
    }
}

struct PaymentMethodTests {
    /// Raw values are persisted. Changing one would break existing data.
    @Test func rawValuesAreStable() {
        #expect(
            PaymentMethod.allCases.map(\.rawValue) == [
                "bar", "girocard", "kreditkarte", "paypal", "ueberweisung", "lastschrift", "sonstige",
            ])
    }

    @Test func everyMethodHasALabel() {
        for method in PaymentMethod.allCases {
            #expect(!method.displayName.isEmpty)
        }
    }
}
