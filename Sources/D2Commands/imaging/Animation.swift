import D2Graphics

public protocol Animation {
    func renderFrame(from image: Image, to graphics: inout Graphics, percent: Double, args: String) throws
}
