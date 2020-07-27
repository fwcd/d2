import D2Utils

public struct EmbossFilter: ImageFilter {
    public let matrices: [Matrix<Double>]

    public init(size: Int) {
        // Size is currently ignored
        matrices = [Matrix([
            [-2, -1, 0],
            [-1, 1, 1],
            [0, 1, 2]
        ])]
    }
}
