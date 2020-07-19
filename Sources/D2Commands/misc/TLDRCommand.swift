import Foundation
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
        // with TF-IDF as a measure of word relevance

        let docs = sentences.map { $0.split(separator: " ").map(String.init) }
        var termDocFreqs = [String: Int]()
        var inverseDocFreqs = [String: Double]()

        for doc in docs {
            for term in Set(doc) {
                termDocFreqs[term] = (termDocFreqs[term] ?? 0) + 1
            }
        }

        for (term, occurringDocCount) in termDocFreqs {
            let idf = log(Double(docs.count) / Double(occurringDocCount))
            inverseDocFreqs[term] = idf
        }

        return docs
            .enumerated()
            .sorted(by: descendingComparator { (_, doc) in doc.map { Double(self.frequencyOf(term: $0, in: doc)) / (inverseDocFreqs[$0] ?? 1) }.reduce(0, +) })
            .prefix(summarySentenceCount)
            .sorted(by: ascendingComparator { $0.0 })
            .map { $0.1.joined(separator: " ") }
    }

    private func frequencyOf(term: String, in doc: [String]) -> Int {
        absoluteFrequencyOf(term: term, in: doc) / (doc.map { absoluteFrequencyOf(term: $0, in: doc) }.max() ?? 1)
    }

    private func absoluteFrequencyOf(term: String, in doc: [String]) -> Int {
        doc.count(forWhich: { $0 == term })
    }
}
