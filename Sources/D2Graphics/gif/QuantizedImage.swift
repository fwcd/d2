/**
 * An image with a reduced color depth.
 */
public protocol QuantizedImage {
    /**
     * The color table associated with this quantization.
     * Must not be greater in size than the `colorCount`
     * specified at initialization.
     */
    var colorTable: [Color] { get }
    
    /**
     * Applies the associated quantization algorithm
     * to create a quantized version of the given image.
     *
     * The `transparentColorIndex` defines a special index which
     * should be used for transparent pixels instead of the
     * color table's value.
     */
    init(fromImage image: Image, colorCount: Int, transparentColorIndex: Int)
    
    /**
     * Fetches the quantized color at the
     * given location.
     */
    subscript(_ y: Int, _ x: Int) -> Int { get }
}
