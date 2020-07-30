import Foundation
import D2MessageIO
import D2NetAPIs
import D2Utils

public class MinecraftModSearchCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Finds a Minecraft mod online",
        longDescription: "Finds a Minecraft mod on CurseForge",
        helpText: "Syntax: [mod name]",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        MinecraftModSearchQuery(term: input).perform().listen {
            switch $0 {
                case .success(let results):
                    if let mod = results.first {
                        let categories = mod.categories ?? []
                        let fileVersions = Dictionary(grouping: mod.gameVersionLatestFiles ?? [], by: { $0.projectFileId })
                        let latestFiles = (mod.latestFiles ?? []).sorted(by: { ($1.fileDate ?? "").lexicographicallyPrecedes($0.fileDate ?? "") })

                        output.append(Embed(
                            title: "\(mod.name ?? "Minecraft Mod") by \((mod.authors ?? []).compactMap { $0.name }.joined(separator: ", "))",
                            description: mod.summary,
                            url: mod.websiteUrl.flatMap(URL.init(string:)),
                            thumbnail: mod.defaultAttachment.flatMap { $0.thumbnailUrl }.flatMap(URL.init(string:)).map(Embed.Thumbnail.init(url:)),
                            footer: Embed.Footer(text: "ID: \(mod.id), Downloads: \(mod.downloadCount ?? -1), Available: \(mod.isAvailable.map { String($0) } ?? "?")"),
                            fields: [
                                Embed.Field(name: "Categories", value: categories.compactMap { $0.name }.joined(separator: ", ").nilIfEmpty ?? "_none_"),
                                Embed.Field(name: "Latest Files", value: latestFiles.compactMap { file in
                                    let details = (file.id == mod.defaultFileId ? ["default"] : [])
                                                + (fileVersions[file.id]?.compactMap { $0.gameVersion } ?? [])
                                    return file.displayName.flatMap { name in
                                        (file.downloadUrl?.replacingOccurrences(of: " ", with: "%20")).map {
                                            "[\(name)](\($0))\(details.joined(separator: ", ").nilIfEmpty.map { " (\($0))" } ?? "")"
                                        }
                                    }
                                }.joined(separator: "\n").nilIfEmpty ?? "_none_")
                            ]
                        ))
                    } else {
                        output.append(errorText: "No search results found")
                    }
                case .failure(let error):
                    output.append(error, errorText: "Search failed")
            }
        }
    }
}
