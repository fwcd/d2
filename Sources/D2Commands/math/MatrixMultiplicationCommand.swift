import SwiftDiscord
import D2Utils

public class MatrixMultiplicationCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Multiplies matrices",
        longDescription: "Performs matrix multiplication",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
    
    private func parseMatrix(from tokens: TokenIterator<String>) -> Matrix<Double>? {
        return nil // TODO
    }
}
