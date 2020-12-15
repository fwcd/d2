import D2MessageIO
import Utils

public class SearchChannelCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Searches for a channel on the current guild",
        requiredPermissionLevel: .vip // TODO: Figure out channel permissions, then filter them correctly and enable it for .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild!")
            return
        }
        guard !input.isEmpty else {
            output.append(errorText: "Please enter something to search for!")
            return
        }

        do {
            let term = input.lowercased()
            let parsedPattern = try? Regex(from: term)
            let pattern = try parsedPattern ?? Regex(from: Regex.escape(term))
            let results = guild.channels.values
                .filter {
                    [$0.name, $0.topic]
                        .compactMap { $0?.lowercased() }
                        .contains { pattern.matchCount(in: $0) > 0 }
                }
                .sorted(by: ascendingComparator { $0.name.levenshteinDistance(to: input) })
                .prefix(5)

            output.append(Embed(
                title: ":mag: Found Channels",
                description: results.map {
                    [
                        "\($0)",
                        $0.topic?.nilIfEmpty
                    ].compactMap { $0 }.joined(separator: "\n")
                }.joined(separator: "\n\n").nilIfEmpty
            ))
        } catch {
            output.append(errorText: "Invalid input: `\(input)`")
        }
    }
}
