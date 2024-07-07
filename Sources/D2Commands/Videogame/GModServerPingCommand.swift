import Utils
import D2MessageIO
import D2NetAPIs

public class GModServerPingCommand: StringCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Pings a Garry's mod (Source) server",
        helpText: "Syntax: [address]:[port]?",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let (host, customPort) = parseHostPort(from: input) else {
            await output.append(info.helpText!)
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
            await output.append(Embed(
                title: "\(info.name) server: \(info.game)",
                footer: "Protocol Version \(info.protocolVersion)",
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
            await output.append(error, errorText: "Could not ping GMod server")
        }
    }
}
