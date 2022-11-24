import D2MessageIO
import D2Permissions
import Utils

public class LogsCommand: StringCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Fetches the logs",
        longDescription: "Outputs the most recently logged lines",
        presented: true,
        requiredPermissionLevel: .admin
    )
    private let defaultLineCount: Int

    public init(defaultLineCount: Int = 10) {
        self.defaultLineCount = defaultLineCount
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        let lineCount = Int(input) ?? defaultLineCount
        let logs = StoringLogHandler.lastOutputs
            .suffix(lineCount)
            .map { $0.replacingOccurrences(of: "```", with: "") }
            .joined(separator: "\n")
        output.append(.code(logs, language: nil))
    }
}
