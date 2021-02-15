import D2NetAPIs
import D2MessageIO

public struct GiphyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Fetches a GIF from Giphy",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter something to search for!")
            return
        }

        GiphySearchQuery(term: input)

    }
}
