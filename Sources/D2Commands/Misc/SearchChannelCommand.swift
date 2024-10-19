import D2MessageIO
import Utils

public class SearchChannelCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Searches for a channel on the current guild",
        requiredPermissionLevel: .mod // TODO: Figure out channel permissions, then filter them correctly and enable it for .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let guild = await context.guild else {
            await output.append(errorText: "Not on a guild!")
            return
        }
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter something to search for!")
            return
        }

        let term = input.lowercased()
        let parsedPattern = try? Regex(term)
        let pattern = (parsedPattern ?? Regex(verbatim: term)).ignoresCase()
        let results = (Array(guild.channels.values) + Array(guild.threads.values))
            .filter {
                [$0.name, $0.topic, $0.parentId.flatMap { guild.channels[$0] }.map(\.name)]
                    .compactMap { $0 }
                    .contains { !$0.matches(of: pattern).isEmpty }
            }
            .sorted(by: ascendingComparator { $0.name.levenshteinDistance(to: input) })
            .prefix(5)

        await output.append(Embed(
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
    }

    private func format(type: Channel.ChannelType) -> String {
        switch type {
            case .text: "Text channels"
            case .voice: "Voice channels"
            case .category: "Categories"
            case .publicThread: "Public threads"
            case .privateThread: "Private threads"
            default: "Other channels"
        }
    }
}
