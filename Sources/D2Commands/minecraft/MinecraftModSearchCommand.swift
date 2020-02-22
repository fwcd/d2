import Foundation
import SwiftDiscord
import D2NetAPIs
import D2Utils

fileprivate let argPattern = try! Regex(from: "\\s*(.*\\S)\\s+(\\d+(?:\\.\\d+))")

public class MinecraftModSearchCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Finds a Minecraft mod online",
        longDescription: "Finds a Minecraft mod on CurseForge",
        helpText: "Syntax: [mod name] [minecraft version]",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if let parsedArgs = argPattern.firstGroups(in: input) {
            MinecraftModSearchQuery(term: parsedArgs[1], gameVersion: parsedArgs[2]).perform {
                switch $0 {
                    case .success(let results):
                        if let mod = results.first {
                            output.append(DiscordEmbed(
                                title: "\(mod.name ?? "Minecraft Mod") by \((mod.authors ?? []).compactMap { $0.name }.joined(separator: ", "))",
                                description: mod.summary,
                                url: mod.websiteUrl.flatMap(URL.init(string:)),
                                thumbnail: mod.defaultAttachment.flatMap { $0.thumbnailUrl }.flatMap(URL.init(string:)).map(DiscordEmbed.Thumbnail.init(url:)),
                                footer: DiscordEmbed.Footer(text: "ID: \(mod.id), Downloads: \(mod.downloadCount ?? -1), Available: \(mod.isAvailable.map { String($0) } ?? "?")"),
                                fields: [
                                    DiscordEmbed.Field(name: "Categories", value: (mod.categories ?? []).compactMap { $0.name }.joined(separator: ",").nilIfEmpty ?? "_none_"),
                                    DiscordEmbed.Field(name: "Latest Files", value: (mod.latestFiles ?? []).compactMap { file in
                                        file.displayName.flatMap { name in file.downloadUrl.map { url in "[\(name)](\(url))" } }
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
        } else {
            output.append(errorText: info.helpText ?? "Could not parse args")
        }
    }
}
