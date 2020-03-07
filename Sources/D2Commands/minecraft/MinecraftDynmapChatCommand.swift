import SwiftDiscord
import D2Utils

public class MinecraftDynmapChatCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Sends a message to a Minecraft server using Dynmap",
        longDescription: "Sends a chat message to a Minecraft Spigot server through the Dynmap API",
        requiredPermissionLevel: .basic
    )

    public init() {}

    private struct SendMessageRequest: Codable {
        private let name: String
        private let message: String
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let jsonData = try JSONEncoder().encode(SendMessageRequest(name: "", message: input))
            guard let json = String(data: jsonData, encoding: .utf8) else {
                output.append(errorText: "Could not encode JSON")
                return
            }
            let request = try HTTPRequest(host: "inf-cau.de", port: 8123, path: "/up/sendmessage", method: "POST", body: json)
            request.runAsync {
                if let .failure(error) = $0 {
                    output.append(error, errorText: "An error occurred while sending the message")
                }
            }
        } catch {
            output.append(error, errorText: "Could not create request")
        }
    }
}
