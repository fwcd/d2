import D2Utils

public struct BoxBlurFilter: ImageFilter {
    public let matrix: Matrix<Double>

    public init(size: Int) {
        matrix = Matrix(repeating: 1, width: size, height: size) / Double(size * size)
    }
}
