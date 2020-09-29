import D2MessageIO
import Logging
import Utils

fileprivate let log = Logger(label: "D2Commands.MatrixMultiplicationCommand")

public class MatrixMultiplicationCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Multiplies matrices",
        longDescription: "Performs matrix multiplication",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .ndArrays

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let factors = allNonNil(input.asNDArrays?.map { $0.asMatrix } ?? [nil]) else {
            output.append(errorText: "Please specify the input in the form of matrices, e.g. `((1, 2), (3, 4)) ((1, 1), (1, 1))`")
            return
        }

        var current: Matrix<Rational>? = nil

        do {
            for rhs in factors {
                if let lhs = current {
                    log.debug("Right-multiplying \(lhs) by \(rhs)")
                    guard lhs.width == rhs.height else {
                        throw ExpressionError.shapeMismatch("Left width (\(lhs.width)) should match right height (\(rhs.height))")
                    }
                    current = lhs * rhs
                } else {
                    current = rhs
                }
            }

            guard let product = current else {
                output.append(errorText: "Empty product")
                return
            }

            log.debug("Computed matrix product \(product)")
            output.append(.ndArrays([product.asNDArray]))
        } catch {
            output.append(error, errorText: "\(error)")
        }
    }
}
