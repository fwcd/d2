import D2Utils
import D2MessageIO

fileprivate let argsPattern = try! Regex(from: "(<#(\\d+)>)?\\s*(\\d+)?")

public class TLDRCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Automatically summarizes the last n messages from the channel",
        helpText: "Syntax: [channel id]? [message count]?",
        requiredPermissionLevel: .basic
    )
    private let maxMessageCount: Int

    public init(maxMessageCount: Int = 80) {
        self.maxMessageCount = maxMessageCount
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let client = context.client, let channelId = context.channel?.id else {
            output.append(errorText: "No MessageIO client/channel/guild available")
            return
        }
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        let messageCount = parsedArgs[1].nilIfEmpty.flatMap(Int.init) ?? 80
        let tldrChannelName = parsedArgs[2].nilIfEmpty.map { ID($0, clientName: client.name) } ?? channelId

        guard messageCount <= maxMessageCount else {
            output.append(errorText: "More than \(maxMessageCount) \("message".pluralize(with: maxMessageCount)) messages are currently not supported")
            return
        }

        // TODO: Support more messages using message db

        client.getMessages(for: tldrChannelName, limit: messageCount) { messages, _ in
            let sentences = messages.flatMap { $0.content.split(separator: ".").map(String.init) }
            let summary = self.summarize(sentences: sentences, summarySentenceCount: min(6, messageCount / 2))
            output.append(Embed(
                title: "TL;DR of the last \(messageCount) \("message".pluralize(with: messageCount))",
                description: summary.joined(separator: " [...] ").nilIfEmpty
            ))
        }
    }

    private func summarize(sentences: [String], summarySentenceCount: Int) -> [String] {
        // Uses the summary algorithm from https://smmry.com/about

        var wordCounts = [String: Int]()

        for sentence in sentences {
            for word in sentence.split(separator: " ").map(String.init) {
                wordCounts[word] = (wordCounts[word] ?? 0) + 1
            }
        }

        return Array(sentences
            .sorted(by: descendingComparator { $0.split(separator: " ").compactMap { wordCounts[String($0)] }.reduce(0, +) })
            .prefix(summarySentenceCount))
    }
}
