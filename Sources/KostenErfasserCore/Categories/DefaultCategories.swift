/// A category the app creates on first launch. Users can rename, recolor,
/// reorder or archive all of them afterwards.
public struct CategoryTemplate: Hashable, Sendable {
    public let name: String
    /// SF Symbol name for the category icon.
    public let symbolName: String
    /// Color as "#RRGGBB".
    public let colorHex: String
    public let subcategories: [String]

    public init(name: String, symbolName: String, colorHex: String, subcategories: [String] = []) {
        self.name = name
        self.symbolName = symbolName
        self.colorHex = colorHex
        self.subcategories = subcategories
    }
}

/// The default category set from the concept (document 01, section "Kategorien").
public enum DefaultCategories {
    public static let all: [CategoryTemplate] = [
        CategoryTemplate(
            name: "Lebensmittel", symbolName: "cart", colorHex: "#2E7D32",
            subcategories: ["Supermarkt", "Bäcker", "Getränke", "Wochenmarkt"]),
        CategoryTemplate(
            name: "Drogerie & Haushalt", symbolName: "basket", colorHex: "#00838F",
            subcategories: ["Drogerie", "Reinigungsmittel", "Haushaltswaren"]),
        CategoryTemplate(
            name: "Restaurant & Café", symbolName: "fork.knife", colorHex: "#EF6C00",
            subcategories: ["Restaurant", "Lieferdienst", "Café", "Kantine"]),
        CategoryTemplate(
            name: "Wohnen", symbolName: "house", colorHex: "#5D4037",
            subcategories: ["Miete", "Nebenkosten", "Strom", "Internet & Telefon", "Rundfunkbeitrag"]),
        CategoryTemplate(
            name: "Mobilität", symbolName: "car", colorHex: "#1565C0",
            subcategories: ["Tanken", "ÖPNV und Deutschlandticket", "Bahn", "Werkstatt", "Parken"]),
        CategoryTemplate(
            name: "Gesundheit", symbolName: "cross.case", colorHex: "#C62828",
            subcategories: ["Apotheke", "Arzt", "Brille", "Fitness"]),
        CategoryTemplate(
            name: "Versicherungen", symbolName: "checkmark.shield", colorHex: "#455A64",
            subcategories: ["Haftpflicht", "Hausrat", "Kfz", "Zusatzversicherung"]),
        CategoryTemplate(
            name: "Freizeit & Hobby", symbolName: "theatermasks", colorHex: "#8E24AA",
            subcategories: ["Kino", "Konzerte", "Sport", "Bücher"]),
        CategoryTemplate(name: "Kleidung & Schuhe", symbolName: "tshirt", colorHex: "#AD1457"),
        CategoryTemplate(
            name: "Elektronik & Software", symbolName: "laptopcomputer", colorHex: "#3949AB",
            subcategories: ["Geräte", "Apps", "Zubehör"]),
        CategoryTemplate(
            name: "Abos & Mitgliedschaften", symbolName: "repeat", colorHex: "#6D4C41",
            subcategories: ["Streaming", "Vereine", "Zeitschriften"]),
        CategoryTemplate(
            name: "Urlaub & Reisen", symbolName: "airplane", colorHex: "#0277BD",
            subcategories: ["Unterkunft", "Anreise", "Aktivitäten"]),
        CategoryTemplate(
            name: "Geschenke & Spenden", symbolName: "gift", colorHex: "#D81B60",
            subcategories: ["Geschenke", "Spenden"]),
        CategoryTemplate(
            name: "Bildung", symbolName: "graduationcap", colorHex: "#F9A825",
            subcategories: ["Kurse", "Fachbücher"]),
        CategoryTemplate(name: "Sonstiges", symbolName: "ellipsis.circle", colorHex: "#757575"),
    ]
}
