import Foundation
import D2Permissions

public class PingCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Replies with 'Pong!'",
        longDescription: "Outputs 'Pong!'",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .none
    public let outputValueType: RichValueType = .text
    private let response: String

    public init(response: String = "Pong") {
        self.response = response
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        let deltaMs = (context.message.timestamp?.timeIntervalSinceNow).map { $0 * -1000.0 }
        let instanceName = context.hostInfo?.instanceName ?? "unknown"
        let message = [
            response,
            deltaMs.map { "in \(String(format: "%.2f", $0)) ms" },
            "(instance: \(instanceName))"
        ].compactMap { $0 }.joined(separator: " ")

        output.append(message)
    }
}
