import Foundation
import D2MessageIO

public class IssueReportCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Provides a link to the bug report form",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append(Embed(
            title: "Click here to create a new issue on GitHub",
            url: URL(string: "https://github.com/fwcd/d2/issues/new")!
        ))
    }
}
