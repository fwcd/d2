import Foundation
import D2MessageIO
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

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        let deltaMs = (context.message.timestamp?.timeIntervalSinceNow).map { $0 * -1000.0 }

        await output.append(Embed(
            title: "Pong in \(deltaMs.map { String(format: "%.2f", $0) } ?? "?") ms",
            footer: "Instance: \(context.hostInfo?.instanceName ?? "unknown")"
        ))
    }
}
