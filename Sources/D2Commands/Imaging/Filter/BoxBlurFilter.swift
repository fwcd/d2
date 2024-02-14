import Utils

public struct BoxBlurFilter: ImageFilter {
    public let matrices: [Matrix<Double>]

    public init(size: Int) {
        matrices = [
            Matrix(repeating: 1, width: size, height: 1) / Double(size),
            Matrix(repeating: 1, width: 1, height: size) / Double(size)
        ]
    }
}
