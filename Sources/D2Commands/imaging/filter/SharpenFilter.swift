import Foundation
import D2Utils

public struct SharpenFilter: ImageFilter {
    public let matrices: [Matrix<Double>]

    public init(size: Int) {
        matrices = [(size, 1), (1, size)].map {
            Matrix(repeating: -1, width: $0.0, height: $0.1)
                .with(Double($0.0 * $0.1), atY: $0.1 / 2, x: $0.0 / 2)
        }
    }
}
