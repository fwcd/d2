import Foundation
import D2MessageIO
import D2NetAPIs
import D2Utils

fileprivate let linkPattern = try! Regex(from: "\\[([\\w\\s]+)\\]")

public class UrbanDictionaryCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Queries UrbanDictionary",
        longDescription: "Queries UrbanDictionary for a term definition",
        helpText: "Syntax: [term]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter a term!")
            return
        }

        UrbanDictionaryQuery(term: input).perform().listen {
            switch $0 {
                case .success(let results):
                    if let entry = results.list.first {
                        output.append(self.embedOf(entry: entry))
                    } else {
                        output.append(errorText: "No results found.")
                    }
                case .failure(let error):
                    output.append(error, errorText: "An error occurred while creating the UrbanDictionary query")
            }
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
        linkPattern.replace(in: formattedText) { "[\($0[1])](https://www.urbandictionary.com/define.php?term=\($0[1].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0[1]))" }
    }
}
