import Foundation
import Utils

public struct SquiggleTransform: ImageTransform {
    public enum Key: String, StringEnum {
        case scale
    }

    private let pos: Vec2<Int>?
    private let scale: Double

    public init(at pos: Vec2<Int>?, kvArgs: [Key: String]) {
        self.pos = pos
        scale = kvArgs[.scale].flatMap { Double($0) } ?? 1
    }

    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        guard scale != 0 else { return destPos }
        let x = Double(destPos.x)
        let y = Double(destPos.y)
        return Vec2<Double>(
            x: x + percent * 30 * sin(y / (4 * scale)),
            y: y + percent * 30 * cos(x / (4 * scale))
        ).floored
    }
}
