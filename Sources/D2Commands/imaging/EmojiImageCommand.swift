import D2Utils
import D2Graphics

public class EmojiImageCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Fetches the image of a custom emoji",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"] // Due to Discord-specific CDN URLs
    )
	public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild")
            return
        }

        guard !input.isEmpty else {
            output.append(errorText: "Please enter the name of an emoji!")
            return
        }

        do {
            let emojis = guild.emojis.values.filter { $0.id != nil }
            guard let emoji = emojis.first(where: { $0.name == input }) else {
                let closest = emojis.min(by: ascendingComparator { $0.name.levenshteinDistance(to: input) })
                output.append(errorText: "Could not find such an emoji!\(closest.map { " Did you mean `\($0.name)`?" } ?? "")")
                return
            }

            try HTTPRequest(
                scheme: "https",
                host: "cdn.discordapp.com",
                path: "/emojis/\(emoji.id!).png"
            ).runAsync {
                do {
                    let data = try $0.get()
                    guard !data.isEmpty else {
                        output.append(errorText: "No emoji image available")
                        return
                    }

                    output.append(.image(try Image(fromPng: data)))
                } catch {
                    output.append(error, errorText: "Could not fetch emoji image")
                }
            }
        } catch {
            output.append(error, errorText: "Could not request emoji image")
        }
    }
}
