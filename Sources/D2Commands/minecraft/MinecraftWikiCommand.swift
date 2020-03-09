import SwiftDiscord
import D2NetAPIs

public class MinecraftWikiCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Queries Minecraft Wiki",
        longDescription: "Queries Minecraft Wiki for an article",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        MinecraftWikiParseQuery(page: input).perform {
            switch $0 {
                case .success(let parse):
                    guard let doc = parse.parse.wikitextDocument else {
                        output.append(errorText: "Could not parse wikitext")
                        return
                    }
                    
                    output.append(DiscordEmbed(
                        title: parse.parse.title,
                        description: doc.introductionLines.joined(separator: "\n").truncate(200, appending: "..."),
                        fields: Array(doc.sections.prefix(5).map { DiscordEmbed.Field(name: $0.title, value: $0.contentLines.joined(separator: "\n").truncate(200, appending: "...")) })
                    ))
                case .failure(let error):
                    output.append(error, errorText: "Could not fetch page from Minecraft wiki")
            }
        }
    }
}
