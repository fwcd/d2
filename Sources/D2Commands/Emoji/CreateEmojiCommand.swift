import Utils
import CairoGraphics

public class CreateEmojiCommand: Command {
    public let info = CommandInfo(
        category: .emoji,
        shortDescription: "Creates an emoji on the current guild",
        helpText: "Syntax: [name]",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let sink = context.sink, let guild = context.guild else {
            await output.append(errorText: "Please make sure that a client and a guild exists!")
            return
        }
        guard let name = input.asText, !name.isEmpty else {
            await output.append(errorText: "Please enter a name for the emoji!")
            return
        }

        guard let encoded = try? ((input.asImage?.pngEncoded()).map { "data:image/png;base64,\($0.base64EncodedString())" }
                                ?? (input.asGif?.encoded()).map { "data:image/gif;base64,\($0.base64EncodedString())" }) else {
            await output.append(errorText: "Please input an image or a GIF!")
            return
        }

        do {
            guard let emoji = try await sink.createEmoji(on: guild.id, name: name, image: encoded) else {
                await output.append(errorText: "Could not create emoji")
                return
            }
            await output.append("Created emoji \(emoji)!")
        } catch {
            await output.append(error, errorText: "Could not create emoji")
        }
    }
}
