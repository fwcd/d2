import D2Utils

public struct SharpenFilter: ImageFilter {
    public let matrix: Matrix<Double>

    public init(size: Int) {
        // Size is currently ignored
        matrix = Matrix([
            [0, -1, 0],
            [-1, 5, -1],
            [0, -1, 0]
        ])
    }
}
