import CairoGraphics
import Utils

public enum UnoColor: String, Hashable, CaseIterable, RichValueConvertible {
    case yellow = "yellow"
    case red = "red"
    case green = "green"
    case blue = "blue"

    public var color: Color {
        switch self {
            case .yellow: return .yellow
            case .red: return .red
            case .green: return .green
            case .blue: return .blue
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
