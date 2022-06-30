public class DallEMiniCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Generates an image from a text prompt using DALL-E mini",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
