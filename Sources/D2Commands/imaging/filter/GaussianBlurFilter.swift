import Utils

fileprivate let accuracy: Int = 4

public struct GaussianBlurFilter: ImageFilter {
    public let matrices: [Matrix<Double>]

    public init(size: Int) {
        // Approximate a Gaussian blur using repeated box blurs
        matrices = Array(repeating: BoxBlurFilter(size: size).matrices, count: accuracy).flatMap { $0 }
    }
}
