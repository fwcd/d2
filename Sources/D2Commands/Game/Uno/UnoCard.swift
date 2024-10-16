import Logging
import CairoGraphics
import Utils

fileprivate let log = Logger(label: "D2Commands.UnoCard")

public enum UnoCard: Hashable, Sendable {
    case number(Int, UnoColor)
    case action(UnoActionLabel, UnoColor?)

    public var color: UnoColor? {
        switch self {
            case let .number(_, color): color
            case let .action(_, color): color
        }
    }

    public var label: UnoActionLabel? {
        switch self {
            case let .action(label, _): label
            default: nil
        }
    }

    public var drawCardCount: Int { return label?.drawCardCount ?? 0 }
    public var skipDistance: Int { return label?.skipDistance ?? 0 }
    public var canPickColor: Bool { return label?.canPickColor ?? false }
    public var image: CairoImage? { return createImage() }

    public static func from(rawLabelOrNum: String, rawColor: String? = nil) throws -> UnoCard {
        let color: UnoColor? = try rawColor.map {
            guard let color = UnoColor(rawValue: $0) else { throw GameError.invalid("card color", $0) }
            return color
        }

        if let n = Int(rawLabelOrNum) {
            guard let c = color else { throw GameError.missing("card color", "Number cards require a color") }
            return .number(n, c)
        } else if let label = UnoActionLabel(rawValue: rawLabelOrNum) {
            return .action(label, color)
        } else {
            throw GameError.invalid("card label", rawLabelOrNum)
        }
    }

    public func canBePlaced(onTopOf other: UnoCard) -> Bool {
        return (color == nil) || (color == other.color) || numberOrLabel(matches: other)
    }

    private func numberOrLabel(matches other: UnoCard) -> Bool {
        switch (self, other) {
            case let (.number(n, _), .number(m, _)): n == m
            case let (.action(a, _), .action(b, _)): a == b
            default: false
        }
    }

    private func createImage() -> CairoImage? {
        do {
            let intSize = Vec2<Int>(x: 100, y: 140)
            let size = intSize.asDouble
            let center = size / 2.0
            let ellipseX = size.x * 0.6
            let ellipseY = center.y - (size.x / 3)
            let cardPadding = size.x / 12
            let renderColor = color?.color ?? .black
            let img = try CairoImage(size: intSize)
            let graphics = CairoContext(image: img)

            graphics.draw(rect: Rectangle(fromX: 0, y: 0, width: size.x, height: size.y, cornerRadius: cardPadding, color: .white))
            graphics.draw(rect: Rectangle(fromX: cardPadding, y: cardPadding, width: size.x - (cardPadding * 2), height: size.y - (cardPadding * 2), cornerRadius: cardPadding, color: renderColor))
            graphics.draw(ellipse: Ellipse(center: center, radius: Vec2(x: ellipseX, y: ellipseY), rotation: -Double.pi / 4.0, color: .white))

            switch self {
                case let .number(n, _):
                    graphics.draw(text: Text(String(n), withSize: size.x * 0.6, at: Vec2(x: size.x * 0.3, y: size.y * 0.65), color: renderColor))
                case let .action(label, _):
                    let icon = try CairoImage(pngFilePath: label.resourcePngPath)
                    let iconSize = Vec2(x: size.x, y: size.x).floored
                    graphics.draw(image: icon, at: center - (iconSize.asDouble / 2), withSize: iconSize)
            }

            return img
        } catch {
            log.warning("Error while creating uno card image: \(error)")
            return nil
        }
    }
}
