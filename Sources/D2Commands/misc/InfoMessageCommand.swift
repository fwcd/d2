import Foundation
import SwiftDiscord
import D2Permissions

/** Displays a static information message. */
public class InfoMessageCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        requiredPermissionLevel: .basic
    )
    private let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append(":information_source: \(text)")
    }
}
