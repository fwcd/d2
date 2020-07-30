import Foundation
import D2MessageIO
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
        MediaWikiParseQuery(host: "minecraft.gamepedia.com", path: "/api.php", page: input, prop: "wikitext").perform().listen {
            do {
                let wikitextParse = try $0.get().parse
                guard let raw = wikitextParse.wikitext else {
                    output.append(errorText: "No wikitext got")
                    return
                }
                let doc = try WikitextParser().parse(raw: raw)
                output.append(Embed(
                    title: wikitextParse.title,
                    description: doc.sections.first.map { self.markdown(from: $0.content) }?.truncate(1000, appending: "...").nilIfEmpty ?? "_no description_",
                    url: wikitextParse.title.flatMap(self.wikiLink(page:)),
                    thumbnail: self.image(from: doc).map(Embed.Thumbnail.init(url:)),
                    color: 0x542900,
                    fields: Array(doc.sections[1...].prefix(5).map {
                        Embed.Field(
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

    private func markdown(from nodes: [WikitextDocument.Section.Node]) -> String {
        nodes.map {
            switch $0 {
                case .text(let text): return text
                case .link(let nodes):
                    switch nodes.count {
                        case 1:
                            let page = markdown(from: nodes[0])
                            return "[\(page)](\(wikiLink(page: page)?.absoluteString ?? page))"
                        case 2:
                            let target = markdown(from: nodes[0])
                            let page = markdown(from: nodes[1])
                            return "[\(page)](\(wikiLink(page: target)?.absoluteString ?? target))"
                        default:
                            return nodes.first.map(markdown(from:)) ?? ""
                    }
                case .template(_, _): return "" // TODO
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

    private func image(from doc: WikitextDocument) -> URL? {
        doc.sections.flatMap { (s: WikitextDocument.Section) -> [WikitextDocument.Section.Node] in
            s.content
        }.flatMap { (n: WikitextDocument.Section.Node) -> [WikitextDocument.Section.Node.TemplateParameter] in
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
