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

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            if let (host, port) = parseHostPort(from: input) {
                let serverInfo = try MinecraftServerPing(host: host, port: port ?? 25565, timeoutMs: 1000).perform()
                let modCount = serverInfo.forgeData?.mods?.count ?? serverInfo.modinfo?.modList?.count

                // TODO: Display server favicon in embed

                output.append(Embed(
                    title: "Minecraft Server at `\(host)\(port.map { ":\($0)" } ?? "")`",
                    description: "\(serverInfo.description)",
                    footer: modCount.map { _ in Embed.Footer(text: "Use \(context.commandPrefix)mcmods to get a detailed mod list") },
                    fields: [
                        Embed.Field(name: "Online", value: "\(serverInfo.players.online) of \(serverInfo.players.max)"),
                        Embed.Field(name: "Players", value: serverInfo.players.sample?.map { $0.name }.joined(separator: "\n") ?? "_no information_"),
                        Embed.Field(name: "Version", value: serverInfo.version.name),
                        Embed.Field(name: "Mods", value: modCount.map { "\($0) \("mod".pluralized(with: $0))" } ?? "_vanilla_")
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
