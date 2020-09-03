import D2Utils
import D2Graphics

public class CreateEmojiCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Creates an emoji on the current guild",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let client = context.client, let guild = context.guild else {
            output.append(errorText: "Please make sure that a client and a guild exists!")
            return
        }
        guard let name = input.asText, !name.isEmpty else {
            output.append(errorText: "Please enter a name for the emoji!")
            return
        }

        if let image = input.asImage {
            Promise.catching { try image.pngEncoded().base64EncodedString() }
                .then { client.createEmoji(on: guild.id, name: name, image: "data:image/png;base64,\($0)") }
                .listen {
                    do {
                        guard let emoji = try $0.get() else {
                            output.append(errorText: "No emoji created!")
                            return
                        }
                        output.append("Created emoji \(emoji)!")
                    } catch {
                        output.append(error, errorText: "Could not create emoji")
                    }
                }
        } else {
            output.append(errorText: "Please input an image or a GIF!")
        }
    }
}
