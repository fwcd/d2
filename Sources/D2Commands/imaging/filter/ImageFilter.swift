import D2Utils

/// A filter used for image processing.
public protocol ImageFilter {
    /// The convolution kernels to be applied
    /// sequentially.
    var matrices: [Matrix<Double>] { get }

    init(size: Int)
}
