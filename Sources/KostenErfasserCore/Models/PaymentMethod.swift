/// How an expense was paid. Raw values are stored, so they must never change.
public enum PaymentMethod: String, Sendable, Codable, CaseIterable {
    case bar
    case girocard
    case kreditkarte
    case paypal
    case ueberweisung
    case lastschrift
    case sonstige

    /// German label for the UI.
    public var displayName: String {
        switch self {
        case .bar: "Bar"
        case .girocard: "Girocard"
        case .kreditkarte: "Kreditkarte"
        case .paypal: "PayPal"
        case .ueberweisung: "Überweisung"
        case .lastschrift: "Lastschrift"
        case .sonstige: "Sonstige"
        }
    }
}
