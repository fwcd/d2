import D2MessageIO
import D2Permissions
import D2Utils

public class LogsCommand: StringCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Fetches the logs",
        longDescription: "Outputs the most recently logged lines",
        requiredPermissionLevel: .admin
    )
    private let defaultLineCount: Int
    
    public init(defaultLineCount: Int = 10) {
        self.defaultLineCount = defaultLineCount
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let lineCount = Int(input) ?? defaultLineCount
        output.append(.code(D2LogHandler.lastOutputs.suffix(lineCount).joined(separator: "\n"), language: nil))
    }
}
