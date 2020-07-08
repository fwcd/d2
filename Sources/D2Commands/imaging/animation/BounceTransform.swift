import Foundation
import D2Utils

public struct BounceTransform: ImageTransform {
    private let pos: Vec2<Int>?

    public init(at pos: Vec2<Int>?, kvArgs: [String: String]) {
        self.pos = pos
    }

    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let relativeYDelta = pow((2 * percent - 1), 2)
        return destPos.with(y: destPos.y - Int(relativeYDelta * Double(imageSize.y)))
    }
}
