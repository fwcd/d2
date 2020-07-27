import Foundation
import D2Utils

public struct SharpenFilter: ImageFilter {
    public let matrices: [Matrix<Double>]

    public init(size: Int) {
        matrices = [(size, 1), (1, size)].map {
            var matrix = Matrix<Double>(repeating: -1, width: $0.0, height: $0.1)
            matrix[$0.1 / 2, $0.0 / 2] = Double($0.0 * $0.1)
            return matrix
        }
    }
}
