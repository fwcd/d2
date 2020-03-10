import Foundation
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
                let doc = try MinecraftWikitextParser().parse(raw: raw)
                output.append(DiscordEmbed(
                    title: wikitextParse.title,
                    url: wikitextParse.title.flatMap(self.wikiLink(page:)),
                    thumbnail: self.image(from: doc).map(DiscordEmbed.Thumbnail.init(url:)),
                    fields: Array(doc.sections.prefix(5).map {
                        DiscordEmbed.Field(
                            name: $0.title ?? "Section",
                            value: self.markdown(from: $0.content).truncate(1000, appending: "...").nilIfEmpty ?? "_no text_"
                        )
                    })
                ))
            } catch {
                output.append(error, errorText: "Could not fetch/parse wikitext from Minecraft wiki")
            }
        }
    }
    
    private func markdown(from nodes: [MinecraftWikitextDocument.Section.Node]) -> String {
        nodes.map {
            switch $0 {
                case .text(let text): return text
                case .link(let page, let target): return "[\(page)](\(wikiLink(page: target ?? page)?.absoluteString ?? page))"
                case .template(let name, let params): return name // TODO
                case .other(let s): return s
                case .unknown: return "?"
            }
        }.joined(separator: " ")
    }
    
    private func wikiLink(page: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "minecraft.gamepedia.com"
        components.path = "/\(page)"
        return components.url
    }
    
    private func image(from doc: MinecraftWikitextDocument) -> URL? {
        doc.sections.flatMap { (s: MinecraftWikitextDocument.Section) -> [MinecraftWikitextDocument.Section.Node] in
            s.content
        }.flatMap { (n: MinecraftWikitextDocument.Section.Node) -> [MinecraftWikitextDocument.Section.Node.TemplateParameter] in
            guard case let .template(_, params) = n else { return [] }
            return params
        }.compactMap {
            guard case let .keyValue(key, params) = $0,
                key.starts(with: "image"),
                case let .text(fileNames) = params.first,
                let fileName = fileNames.split(separator: ";").first else { return nil }
            var components = URLComponents()
            components.scheme = "https"
            components.host = "minecraft.gamepedia.com"
            components.path = "/Special:Filepath/\(fileName)"
            return components.url
        }.first
    }
}
