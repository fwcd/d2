import Foundation
import Logging
import D2MessageIO
import Utils

private let log = Logger(label: "D2Commands.MinecraftDynmapChatCommand")

public class MinecraftDynmapChatCommand: RegexCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Sends a message to a Minecraft server using Dynmap",
        longDescription: "Sends a chat message to a Minecraft Spigot server through the Dynmap API",
        helpText: "Syntax: [server host] [message]",
        requiredPermissionLevel: .basic
    )

    public let inputPattern = #/(?<host>\S+)\s+(?<message>.+)/#

    public init() {}

    private struct SendMessageRequest: Sendable, Codable {
        let name: String
        let message: String
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        do {
            let host = String(input.host)
            let message = "[\(context.author?.username ?? "unknown user")] \(input.message)"

            log.info("Sending chat message '\(message)' to host '\(host)'")

            let jsonData = try JSONEncoder().encode(SendMessageRequest(name: "", message: message))
            guard let json = String(data: jsonData, encoding: .utf8) else {
                await output.append(errorText: "Could not encode JSON")
                return
            }
            do {
                let request = try HTTPRequest(scheme: "http", host: host, port: 8123, path: "/up/sendmessage", method: "POST", body: json)
                try await request.run()
            } catch {
                await output.append(error, errorText: "An error occurred while sending the message")
            }
        } catch {
            await output.append(error, errorText: "Could not create request")
        }
    }
}
