import D2Utils

public struct TwirlTransform: ImageTransform {
    private let pos: Vec2<Int>?

    public init(at pos: Vec2<Int>?) {
        self.pos = pos
    }
    
    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let center = pos ?? (imageSize / 2)
        let delta = center - destPos
        let dist = delta.magnitude

        fatalError("Not implemented") // TODO
    }
}
