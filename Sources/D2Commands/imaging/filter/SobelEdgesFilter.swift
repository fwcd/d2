import D2Utils

public struct SobelEdgesFilter<IsHorizontal: ConstBool>: ImageFilter {
    public let matrices: [Matrix<Double>]

    public init(size: Int) {
        let halfSize = size / 2
        let matrices = [
            Matrix([Array(repeating: 1, count: size)]).with(2, atY: 0, x: halfSize).transpose,
            Matrix([(0..<size).map { Double(($0 - halfSize).signum()) }])
        ]

        if IsHorizontal.value {
            self.matrices = matrices
        } else {
            self.matrices = matrices.reversed().map(\.transpose)
        }
    }
}
