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
    private let logBuffer: LogBuffer

    public init(defaultLineCount: Int = 10, logBuffer: LogBuffer) {
        self.defaultLineCount = defaultLineCount
        self.logBuffer = logBuffer
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let lineCount = Int(input) ?? defaultLineCount
        let logs = await logBuffer.lastOutputs
            .suffix(lineCount)
            .map { $0.replacingOccurrences(of: "```", with: "") }
            .joined(separator: "\n")
        await output.append(.code(logs, language: nil))
    }
}
