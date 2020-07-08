import D2Utils
import D2Graphics

public protocol Animation: KeyParameterizable {
    init(pos: Vec2<Int>?, kvArgs: [Key: String]) throws

    func renderFrame(from image: Image, to frame: inout Image, percent: Double) throws
}
