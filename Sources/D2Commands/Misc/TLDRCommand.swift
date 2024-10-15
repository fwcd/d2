import Foundation
import Utils
import D2MessageIO

public class TLDRCommand: RegexCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Automatically summarizes the last n messages from the channel",
        helpText: "Syntax: [channel id]? [message count]?",
        requiredPermissionLevel: .basic
    )

    public let inputPattern = #/(?:<#(?<channelId>\d+)>)?\s*(?<count>\d+)?/#

    private let maxMessageCount: Int
    private let highlightThreshold: Double
    private let capitalizedFactor: Int
    private let maxSentenceCount: Int

    public init(
        maxMessageCount: Int = 80,
        highlightThreshold: Double = .infinity,
        capitalizedFactor: Int = 3,
        maxSentenceCount: Int = 5
    ) {
        self.maxMessageCount = maxMessageCount
        self.highlightThreshold = highlightThreshold
        self.capitalizedFactor = capitalizedFactor
        self.maxSentenceCount = maxSentenceCount
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        guard let sink = context.sink, let channelId = context.channel?.id else {
            await output.append(errorText: "No MessageIO client/channel/guild available")
            return
        }

        let tldrChannelName = input.channelId.map { ID(String($0), clientName: sink.name) } ?? channelId
        let messageCount = input.count.flatMap { Int($0) } ?? 80

        guard messageCount <= maxMessageCount else {
            await output.append(errorText: "More than \(maxMessageCount) \("message".pluralized(with: maxMessageCount)) messages are currently not supported")
            return
        }

        // TODO: Support more messages using message db

        do {
            let messages = try await sink.getMessages(for: tldrChannelName, limit: messageCount)
            let sentences = messages
                .sorted(by: ascendingComparator { $0.timestamp ?? .distantPast })
                .flatMap { $0.content.split(separator: ".").map(String.init) }
            let summary = self.summarize(sentences: sentences, summarySentenceCount: min(self.maxSentenceCount, messageCount / 2))

            await output.append(Embed(
                title: "TL;DR of the last \(messageCount) \("message".pluralized(with: messageCount))",
                description: summary.joined(separator: " [...] ").nilIfEmpty
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch messages")
        }
    }

    private func summarize(sentences: [String], summarySentenceCount: Int = 6) -> [String] {
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

        func tfIdfOf(term: String, in doc: [String], prioritizeCapitalized: Bool) -> Double {
            frequencyOf(term: term, in: doc, prioritizeCapitalized: prioritizeCapitalized) / (inverseDocFreqs[term] ?? 1)
        }

        let ts: [(Int, [(Double, String)])] = docs
            .enumerated()
            .map { (i, doc) in (i, doc.enumerated().map { (i, t) in (tfIdfOf(term: t, in: doc, prioritizeCapitalized: i > 0), t) }) }
            .sorted(by: descendingComparator { (_, d) in d.map(\.0).reduce(0, +) })
            .prefix(summarySentenceCount)
            .sorted(by: ascendingComparator { $0.0 })

        return ts
            .map { (_, d) in d.map { $0.0 > highlightThreshold ? "**\($0.1)**" : $0.1 }.joined(separator: " ") }
    }

    private func frequencyOf(term: String, in doc: [String], prioritizeCapitalized: Bool = true) -> Double {
        let current = Double(absoluteFrequencyOf(term: term, in: doc))
        let total = Double(doc.map { absoluteFrequencyOf(term: $0, in: doc, prioritizeCapitalized: prioritizeCapitalized) }.max() ?? 1)
        return current / total
    }

    private func absoluteFrequencyOf(term: String, in doc: [String], prioritizeCapitalized: Bool = true) -> Int {
        let factor = prioritizeCapitalized && (term.first?.isUppercase ?? false) ? capitalizedFactor : 1
        return doc.count(forWhich: { $0 == term }) * factor
    }
}
