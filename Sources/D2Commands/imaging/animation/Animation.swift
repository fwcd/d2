import D2Graphics

public protocol Animation {
    init(args: String) throws

    func renderFrame(from image: Image, to frame: inout Image, percent: Double) throws
}
