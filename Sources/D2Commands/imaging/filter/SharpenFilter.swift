import D2Utils

public struct SharpenFilter: ImageFilter {
    public let matrices: [Matrix<Double>]

    public init(size: Int) {
        // Size is currently ignored
        matrices = [Matrix([
            [0, -1, 0],
            [-1, 5, -1],
            [0, -1, 0]
        ])]
    }
}
