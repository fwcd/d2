import Foundation
import D2MessageIO
import D2NetAPIs
import Utils

public class FTBModpacksCommand: StringCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Fetches a list of FTB modpacks",
        longDescription: "Fetches a list of recent Feed The Beast modpacks with descriptions and download links",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        FTBModpacksQuery().perform().listen {
            do {
                let packs = try $0.get().prefix(5)
                output.append(Embed(
                    title: "Recent FTB Modpacks",
                    image: (packs.last?.imageUrl).flatMap(URL.init(string:)).map(Embed.Image.init(url:)),
                    fields: packs.map {
                        Embed.Field(
                            name: "\($0.name ?? "?")\($0.mcVersion.map { " (\($0))" } ?? "")",
                            value: """
                                [[Download Pack]](\($0.downloadUrl ?? "")) [[Download Server]](\($0.serverDownloadUrl ?? ""))
                                \($0.description?
                                    .replacingOccurrences(of: "<br>", with: "\n")
                                    .replacingOccurrences(of: "\n\n", with: "\n")
                                    .truncate(300, appending: "...") ?? "_no description_")
                                """
                        )
                    }
                ))
            } catch {
                output.append(error, errorText: "Could not fetch recent FTB modpacks")
            }
        }
    }
}
