import Foundation
import SwiftDiscord
import D2NetAPIs
import D2Utils

fileprivate let linkPattern = try! Regex(from: "\\[(\\w+)\\]")

public class UrbanDictionaryCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Queries UrbanDictionary",
        longDescription: "Queries UrbanDictionary for a term definition",
        helpText: "Syntax: [term]",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter a term!")
            return
        }

        UrbanDictionaryQuery(term: input).perform {
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
    
    private func embedOf(entry: UrbanDictionaryEntry) -> DiscordEmbed {
        return DiscordEmbed(
            title: ":blue_book: \(entry.word)",
            description: markdownOf(formattedText: entry.definition),
            url: entry.permalink.flatMap { URL(string: $0) },
            color: 0x0018b5,
            footer: DiscordEmbed.Footer(text: "Author: \(entry.author ?? "?")"),
            fields: [
                DiscordEmbed.Field(name: "Example", value: entry.example.map(markdownOf) ?? "_no example_"),
                DiscordEmbed.Field(name: "Rating", value: ":thumbsup: \(entry.thumbsUp ?? 0) :thumbsdown: \(entry.thumbsDown ?? 0)")
            ]
        )
    }
    
    private func markdownOf(formattedText: String) -> String {
        linkPattern.replace(in: formattedText, with: "[$1](https://www.urbandictionary.com/define.php?term=$1)")
    }
}
