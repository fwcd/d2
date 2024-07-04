import Foundation
import D2MessageIO
import D2Permissions

/// Displays a static information message.
public class InfoMessageCommand: VoidCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Displays a static information message",
        requiredPermissionLevel: .basic
    )
    private let text: String

    public init(text: String) {
        self.text = text
    }

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        await output.append(":information_source: \(text)")
    }
}
