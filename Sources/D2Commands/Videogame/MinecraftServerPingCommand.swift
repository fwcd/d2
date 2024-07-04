import Foundation
import Logging
import Socket
import D2MessageIO
import Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.MinecraftServerPingCommand")

public class MinecraftServerPingCommand: StringCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Pings a Minecraft server",
        longDescription: "Fetches the Message of the Day (MOTD) and the current player list of a Minecraft server",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            if let (host, port) = parseHostPort(from: input) {
                let serverInfo = try MinecraftServerPing(host: host, port: port ?? 25565, timeoutMs: 1000).perform()
                let modCount = serverInfo.forgeData?.mods?.count ?? serverInfo.modinfo?.modList?.count
                let faviconImage = serverInfo.faviconImage

                await output.append(.compound([
                    .embed(Embed(
                        title: "Minecraft Server at `\(host)\(port.map { ":\($0)" } ?? "")`",
                        description: "\(serverInfo.description)",
                        thumbnail: URL(string: "attachment://favicon.png").filter { _ in faviconImage != nil }.map { Embed.Thumbnail(url: $0) },
                        footer: modCount.map { _ in Embed.Footer(text: "Use \(context.commandPrefix)mcmods to get a detailed mod list") },
                        fields: [
                            Embed.Field(name: "Online", value: "\(serverInfo.players.online) of \(serverInfo.players.max)"),
                            Embed.Field(name: "Players", value: serverInfo.players.sample?.map { $0.name }.joined(separator: "\n").nilIfEmpty ?? "_no information_"),
                            Embed.Field(name: "Version", value: serverInfo.version.name.nilIfEmpty ?? "_no information_"),
                            Embed.Field(name: "Mods", value: modCount.map { "\($0) \("mod".pluralized(with: $0))" } ?? "_vanilla_")
                        ]
                    )),
                    .files([
                        faviconImage.flatMap { try? $0.pngEncoded() }.map { Message.FileUpload(data: $0, filename: "favicon.png", mimeType: "image/png") }
                    ].compactMap { $0 })
                ]))
            } else {
                await output.append(errorText: "Could not parse host/port, please specify it using the following format: `localhost:25565`")
            }
        } catch {
            await output.append(error, errorText: "Could not ping server")
        }
    }
}
