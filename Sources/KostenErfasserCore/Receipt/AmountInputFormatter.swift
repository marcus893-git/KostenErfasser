/// Formats an amount for editing in a text field: "1234,56", "-1,50".
/// The result can be read back with `AmountParser.parseCents`.
public enum AmountInputFormatter {
    public static func text(for money: Money) -> String {
        let sign = money.cents < 0 ? "-" : ""
        let absolute = money.cents.magnitude
        let fraction = absolute % 100
        return "\(sign)\(absolute / 100)," + (fraction < 10 ? "0\(fraction)" : "\(fraction)")
    }
}
