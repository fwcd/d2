import SwiftDiscord
import D2NetAPIs
import D2Utils

public class MinecraftWikiCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Queries Minecraft Wiki",
        longDescription: "Queries Minecraft Wiki for an article",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        MinecraftWikiParseQuery(page: input, prop: "wikitext").perform {
            do {
                let wikitextParse = try $0.get().parse
                guard let raw = wikitextParse.wikitext else {
                    output.append(errorText: "No wikitext got")
                    return
                }
                print(raw)
                let doc = try MinecraftWikitextParser().parse(raw: raw)
                print(doc)
                // output.append(DiscordEmbed(
                //     title: sectionsParse.parse.title,
                //     fields: Array(wikitextParses.prefix(5).map {
                //         DiscordEmbed.Field(
                //             name: "Section", // TODO: Extract section title from sectionsParse using index
                //             value: $0.parse.wikitext?.truncate(200, appending: "...") ?? "_no text_" // TODO: Parse/format
                //         )
                //     })
                // ))
            } catch {
                output.append(error, errorText: "Could not fetch/parse wikitext from Minecraft wiki")
            }
        }
    }
}
