import Logging
import Socket
import SwiftDiscord
import D2Utils
import D2NetAPIs

fileprivate let log = Logger(label: "MinecraftServerPingCommand")

public class MinecraftServerPingCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Pings a Minecraft server",
        longDescription: "Fetches the Message of the Day (MOTD) and the current player list of a Minecraft server",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            if let (host, port) = parseMcHostPort(from: input) {
                let serverInfo = try MinecraftServerPing(host: host, port: port, timeoutMs: 1000).perform()
                let modCount = serverInfo.forgeData?.mods?.count ?? serverInfo.modinfo?.modList?.count
                
                // TODO: Display server favicon in embed
                
                output.append(DiscordEmbed(
                    title: "Minecraft Server at `\(host):\(port)`",
                    description: "\(serverInfo.description)",
                    footer: modCount.map { _ in DiscordEmbed.Footer(text: "Use \(context.commandPrefix)mcmods to get a detailed mod list") },
                    fields: [
                        DiscordEmbed.Field(name: "Online", value: "\(serverInfo.players.online) of \(serverInfo.players.max)"),
                        DiscordEmbed.Field(name: "Players", value: serverInfo.players.sample?.map { $0.name }.joined(separator: "\n") ?? "_no information_"),
                        DiscordEmbed.Field(name: "Version", value: serverInfo.version.name),
                        DiscordEmbed.Field(name: "Mods", value: modCount.map { "\($0) \("mod".pluralize(with: $0))" } ?? "_vanilla_")
                    ]
                ))
            } else {
                output.append(errorText: "Could not parse host/port, please specify it using the following format: `localhost:25565`")
            }
        } catch {
            output.append(error, errorText: "Could not ping server")
        }
    }
}
