import Utils
import CairoGraphics

public class EmojiImageCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Fetches the image of a custom emoji",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"] // Due to Discord-specific CDN URLs
    )
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild")
            return
        }

        guard !input.isEmpty else {
            output.append(errorText: "Please enter the name of an emoji!")
            return
        }

        let emojis = guild.emojis.values.filter { $0.id != nil }
        guard let emoji = emojis.first(where: { $0.name == input }) else {
            let closest = emojis.min(by: ascendingComparator { $0.name.levenshteinDistance(to: input) })
            output.append(errorText: "Could not find such an emoji!\(closest.map { " Did you mean `\($0.name)`?" } ?? "")")
            return
        }

        Promise.catching { try HTTPRequest(
            scheme: "https",
            host: "cdn.discordapp.com",
            path: "/emojis/\(emoji.id!).png"
        ) }
            .then { $0.runAsync() }
            .listen {
                do {
                    let data = try $0.get()
                    guard !data.isEmpty else {
                        output.append(errorText: "No emoji image available")
                        return
                    }

                    output.append(.image(try CairoImage(pngData: data)))
                } catch {
                    output.append(error, errorText: "Could not fetch emoji image")
                }
            }
    }
}
