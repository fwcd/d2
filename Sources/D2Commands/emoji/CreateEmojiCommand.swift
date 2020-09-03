import D2Utils
import D2Graphics

public class CreateEmojiCommand: Command {
    public let info = CommandInfo(
        category: .emoji,
        shortDescription: "Creates an emoji on the current guild",
        helpText: "Syntax: [name]",
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

        guard let encoded = try? ((input.asImage?.pngEncoded()).map { "data:image/png;base64,\($0.base64EncodedString())" }
                               ?? (input.asGif?.encoded()).map { "data:image/gif;base64,\($0.base64EncodedString())" }) else {
            output.append(errorText: "Please input an image or a GIF!")
            return
        }

        client.createEmoji(on: guild.id, name: name, image: encoded)
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
    }
}
