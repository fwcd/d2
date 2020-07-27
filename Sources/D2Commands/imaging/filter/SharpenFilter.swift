import D2Utils

public struct SharpenFilter: ImageFilter {
    public let matrix: Matrix<Double>

    public init(size: Int) {
        var matrix = Matrix<Double>(repeating: -1, width: size, height: size)
        matrix[size / 2, size / 2] = Double((size * size) - 1)
        self.matrix = matrix
    }
}
