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
        guard let (host, customPort) = parseHostPort(from: input) else {
            output.append(info.helpText!)
            return
        }
        let port = customPort ?? 27015
        
        do {
            let info: SourceServerInfoResponse = try SourceServerQuery(
                request: SourceServerInfoRequest(),
                host: host,
                port: port,
                timeoutMs: 1000
            ).perform()
            let players = (try? SourceServerQuery<SourceServerPlayerRequest, SourceServerChallengeResponse>(
                request: SourceServerPlayerRequest(challenge: 0xFFFFFFFF),
                host: host,
                port: port,
                timeoutMs: 1000
            ).perform()).flatMap { rsp in try? SourceServerQuery<SourceServerPlayerRequest, SourceServerPlayerResponse>(
                request: SourceServerPlayerRequest(challenge: rsp.challenge),
                host: host,
                port: port,
                timeoutMs: 1000
            ).perform() }
            output.append(Embed(
                title: "\(info.name) server: \(info.game)",
                footer: Embed.Footer(text: "Protocol Version \(info.protocolVersion)"),
                fields: [
                    Embed.Field(name: "Map", value: info.map),
                    Embed.Field(name: "Players", value: """
                        \(info.players) of \(info.maxPlayers)
                        \(players?.players.map { "\($0.name) (score: \($0.score))" }.joined(separator: "\n").nilIfEmpty ?? "_no player info_")
                        """),
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
