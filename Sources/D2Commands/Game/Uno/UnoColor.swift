@preconcurrency import CairoGraphics
import Utils

public enum UnoColor: String, Hashable, Sendable, CaseIterable, RichValueConvertible {
    case yellow = "yellow"
    case red = "red"
    case green = "green"
    case blue = "blue"

    public var color: Color {
        switch self {
            case .yellow: .yellow
            case .red: .red
            case .green: .green
            case .blue: .blue
        }
    }

    public var asRichValue: RichValue {
        switch self {
            case .yellow: .text(":large_orange_diamond:")
            case .red: .text(":red_circle:")
            case .green: .text(":green_book:")
            case .blue: .text(":large_blue_diamond:")
        }
    }
}
