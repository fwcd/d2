import D2Utils
import D2MessageIO
import D2NetAPIs

public class GModServerPingCommand: StringCommand {
    public let info = CommandInfo(
        category: .gmod,
        shortDescription: "Pings a GMod server",
        helpText: "Syntax: [address]:[port]?",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let (host, port) = parseHostPort(from: input) else {
            output.append(info.helpText!)
            return
        }
        
        do {
            let info = try SourceServerPing(host: host, port: port ?? 27015, timeoutMs: 1000).perform()
            output.append(Embed(
                title: "GMod Server: \(info.name)",
                footer: Embed.Footer(text: "Protocol Version \(info.protocolVersion)"),
                fields: [
                    Embed.Field(name: "Map", value: info.map),
                    Embed.Field(name: "Game", value: info.game),
                    Embed.Field(name: "Players", value: "\(info.players) of \(info.maxPlayers)"),
                    Embed.Field(name: "Bots", value: "\(info.bots)"),
                    Embed.Field(name: "Server", value: """
                        Type: \(info.serverType)
                        Environment: \(info.environment)
                        Public: \(info.isPublic)
                        Uses VAC: \(info.usesVAC)
                        """)
                ]
            ))
        } catch {
            output.append(error, errorText: "Could not ping GMod server")
        }
    }
}
