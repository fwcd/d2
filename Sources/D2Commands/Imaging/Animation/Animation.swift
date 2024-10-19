import Utils
@preconcurrency import CairoGraphics

public protocol Animation: KeyParameterizable {
    init(pos: Vec2<Int>?, kvArgs: [Key: String]) throws

    func renderFrame(from image: CairoImage, to frame: CairoImage, percent: Double) throws
}
