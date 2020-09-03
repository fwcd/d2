import SwiftSoup

public class ParseDOMCommand: StringCommand {
    public let info = CommandInfo(
        category: .web,
        shortDescription: "Parses HTML into a tree of DOM nodes/elements",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            output.append(.domNode(try SwiftSoup.parse(input)))
        } catch {
            output.append(error, errorText: "Could not parse DOM")
        }
    }
}
