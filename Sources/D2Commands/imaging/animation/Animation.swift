import D2Utils
import D2Graphics

public protocol Animation {
    static var kvParameters: [String] { get }

    init(pos: Vec2<Int>?, kvArgs: [String: String]) throws

    func renderFrame(from image: Image, to frame: inout Image, percent: Double) throws
}

public extension Animation {
    static var kvParameters: [String] { [] }
}
