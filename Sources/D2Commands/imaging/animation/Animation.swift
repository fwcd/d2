import D2Graphics

public protocol Animation {
    func renderFrame(from image: Image, to frame: inout Image, percent: Double, args: String) throws
}
