import D2MessageIO
import Utils

public class SearchChannelCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Searches for a channel on the current guild",
        requiredPermissionLevel: .vip // TODO: Figure out channel permissions, then filter them correctly and enable it for .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
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
            let results = (Array(guild.channels.values) + Array(guild.threads.values))
                .filter {
                    [$0.name, $0.topic, $0.parentId.flatMap { guild.channels[$0] }.map(\.name)]
                        .compactMap { $0?.lowercased() }
                        .contains { pattern.matchCount(in: $0) > 0 }
                }
                .sorted(by: ascendingComparator { $0.name.levenshteinDistance(to: input) })
                .prefix(5)

            output.append(Embed(
                title: ":mag: Found Channels",
                fields: Dictionary(grouping: results, by: \.type)
                    .sorted(by: ascendingComparator { [.text, .publicThread, .privateThread, .voice, .category].firstIndex(of: $0.key) ?? Int.max })
                    .map {
                        Embed.Field(
                            name: format(type: $0.key),
                            value: $0.value
                                .map { [
                                    "\($0)",
                                    $0.topic.filter { !$0.isEmpty }.map { ": \($0)" },
                                    $0.parentId.flatMap { guild.channels[$0] }.map { " _in \($0.name)_" }
                                ].compactMap { $0 }.joined() }
                                .joined(separator: "\n")
                        )
                    }
            ))
        } catch {
            output.append(errorText: "Invalid input: `\(input)`")
        }
    }

    private func format(type: Channel.ChannelType) -> String {
        switch type {
            case .text: return "Text channels"
            case .voice: return "Voice channels"
            case .category: return "Categories"
            case .publicThread: return "Public threads"
            case .privateThread: return "Private threads"
            default: return "Other channels"
        }
    }
}
