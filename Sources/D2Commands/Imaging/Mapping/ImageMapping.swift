@preconcurrency import CairoGraphics

/// A simple function from image to image that
/// is either applied directly to an image or
/// per-frame to a GIF.
public protocol ImageMapping {
    init(args: String?) throws

    func apply(to image: CairoImage) throws -> CairoImage
}
