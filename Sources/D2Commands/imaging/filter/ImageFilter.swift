import D2Utils

/// A convolution kernel used for image processing.
public protocol ImageFilter {
    var matrix: Matrix<Double> { get }

    init(size: Int)
}
