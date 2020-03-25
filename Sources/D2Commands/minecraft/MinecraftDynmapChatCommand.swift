import Foundation
import Logging
import D2MessageIO
import D2Utils

fileprivate let log = Logger(label: "D2Commands.MinecraftDynmapChatCommand")
fileprivate let argsPattern = try! Regex(from: "(\\S+)\\s+(.+)")

public class MinecraftDynmapChatCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Sends a message to a Minecraft server using Dynmap",
        longDescription: "Sends a chat message to a Minecraft Spigot server through the Dynmap API",
        helpText: "Syntax: [server host] [message]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    private struct SendMessageRequest: Codable {
        let name: String
        let message: String
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            guard let parsedArgs = argsPattern.firstGroups(in: input) else {
                output.append("Syntax: \(info.helpText!)")
                return
            }
            let host = parsedArgs[1]
            let message = "[\(context.author?.username ?? "unknown user")] \(parsedArgs[2])"
            
            log.info("Sending chat message '\(message)' to host '\(host)'")

            let jsonData = try JSONEncoder().encode(SendMessageRequest(name: "", message: message))
            guard let json = String(data: jsonData, encoding: .utf8) else {
                output.append(errorText: "Could not encode JSON")
                return
            }
            let request = try HTTPRequest(scheme: "http", host: host, port: 8123, path: "/up/sendmessage", method: "POST", body: json)
            request.runAsync {
                if case let .failure(error) = $0 {
                    output.append(error, errorText: "An error occurred while sending the message")
                }
            }
        } catch {
            output.append(error, errorText: "Could not create request")
        }
    }
}
