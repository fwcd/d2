import D2Graphics
import D2Utils

public enum UnoColor: String, Hashable, CaseIterable, RichValueConvertible {
    case yellow = "yellow"
    case red = "red"
    case green = "green"
    case blue = "blue"

    public var color: Color {
        switch self {
            case .yellow: return Colors.yellow
            case .red: return Colors.red
            case .green: return Colors.green
            case .blue: return Colors.blue
        }
    }

    public var asRichValue: RichValue {
        switch self {
            case .yellow: return .text(":large_orange_diamond:")
            case .red: return .text(":red_circle:")
            case .green: return .text(":green_book:")
            case .blue: return .text(":large_blue_diamond:")
        }
    }
}
