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
        MinecraftWikiParseQuery(page: input, prop: "sections").perform {
            switch $0 {
                case .success(let sectionsParse):
                    collect(thenables: sectionsParse.parse.sections?.compactMap { $0.index }.map { i in { MinecraftWikiParseQuery(page: input, prop: "wikitext", section: i).perform(then: $0) } } ?? []) {
                        switch $0 {
                            case .success(let wikitextParses):
                                output.append(DiscordEmbed(
                                    title: sectionsParse.parse.title,
                                    fields: Array(wikitextParses.prefix(5).map {
                                        DiscordEmbed.Field(
                                            name: "Section", // TODO: Extract section title from sectionsParse using index
                                            value: $0.parse.wikitext?.truncate(200, appending: "...") ?? "_no text_" // TODO: Parse/format
                                        )
                                    })
                                ))
                            case .failure(let error):
                                output.append(error, errorText: "Could not fetch section text from Minecraft wiki")
                        }
                    }
                case .failure(let error):
                    output.append(error, errorText: "Could not fetch sections from Minecraft wiki")
            }
        }
    }
}
