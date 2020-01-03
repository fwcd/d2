import Socket
import SwiftDiscord
import D2Utils
import D2NetAPIs

fileprivate let hostPortPattern = try! Regex(from: "([^:]+)(?::(\\d+))?")

public class MinecraftServerPingCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Pings a Minecraft Server",
        longDescription: "Fetches the Message of the Day (MOTD) and the current player list of a Minecraft Server",
        requiredPermissionLevel: .vip
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            if let parsedHostPort = hostPortPattern.firstGroups(in: input) {
                let host = parsedHostPort[1]
                let port = Int32(parsedHostPort[2]) ?? 25565
                let serverInfo = try MinecraftServerPing(host: host, port: port, timeoutMs: 1000).perform()
                
                output.append(DiscordEmbed(
                    title: "Minecraft Server at `\(host):\(port)`",
                    description: serverInfo.description.text,
                    fields: [
                        DiscordEmbed.Field(name: "Online", value: "\(serverInfo.players.online) of \(serverInfo.players.max)"),
                        DiscordEmbed.Field(name: "Players", value: serverInfo.players.sample?.map { $0.name }.joined(separator: "\n") ?? "_no information_")
                    ]
                ))
            } else {
                output.append("Could not parse host/port, please specify it using the following format: `localhost:25565`")
            }
        } catch {
            print(error)
            output.append("Could not ping server")
        }
    }
}
