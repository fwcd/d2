import D2Utils

public struct HorizontalSobelEdgesFilter: ImageFilter {
    public let matrix: Matrix<Double>

    public init(size: Int) {
        // Size is currently ignored
        matrix = Matrix([
            [1, 0, -1],
            [2, 0, -2],
            [1, 0, -1]
        ])
    }
}

public struct VerticalSobelEdgesFilter: ImageFilter {
    public let matrix: Matrix<Double>

    public init(size: Int) {
        // Size is currently ignored
        matrix = Matrix([
            [1, 2, 1],
            [0, 0, 0],
            [-1, -2, -1]
        ])
    }
}
