import Foundation
import D2MessageIO
import D2NetAPIs
import Utils

nonisolated(unsafe) private let linkPattern = #/\[(?<term>[\w\s]+)\]/#

public class UrbanDictionaryCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Queries UrbanDictionary",
        longDescription: "Queries UrbanDictionary for a term definition",
        helpText: "Syntax: [term]",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a term!")
            return
        }

        do {
            let results = try await UrbanDictionaryQuery(term: input).perform()
            if let entry = results.list.first {
                await output.append(self.embedOf(entry: entry))
            } else {
                await output.append(errorText: "No results found.")
            }
        } catch {
            await output.append(error, errorText: "An error occurred while creating the UrbanDictionary query")
        }
    }

    private func embedOf(entry: UrbanDictionaryEntry) -> Embed {
        Embed(
            title: ":blue_book: \(entry.word)",
            description: markdownOf(formattedText: entry.definition),
            url: entry.permalink.flatMap { URL(string: $0) },
            color: 0x0018b5,
            footer: Embed.Footer(text: "Author: \(entry.author ?? "?")"),
            fields: [
                Embed.Field(name: "Example", value: entry.example.map(markdownOf) ?? "_no example_"),
                Embed.Field(name: "Rating", value: ":thumbsup: \(entry.thumbsUp ?? 0) :thumbsdown: \(entry.thumbsDown ?? 0)")
            ]
        )
    }

    private func markdownOf(formattedText: String) -> String {
        formattedText.replacing(linkPattern) { "[\($0.term)](https://www.urbandictionary.com/define.php?term=\($0.term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? String($0.term)))" }
    }
}
