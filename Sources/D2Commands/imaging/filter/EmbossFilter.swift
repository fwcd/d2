import D2Utils

public struct EmbossFilter: ImageFilter {
    public let matrix: Matrix<Double>

    public init(size: Int) {
        // Size is currently ignored
        matrix = Matrix([
            [-2, -1, 0],
            [-1, 1, 1],
            [0, 1, 2]
        ])
    }
}
