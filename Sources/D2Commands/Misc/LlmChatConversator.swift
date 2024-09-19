import Utils
import D2MessageIO

public struct LlmChatConversator: Conversator {
    private let session: NodePackage.JsonSession

    private struct Request: Codable {
        var message: String
        var systemMessage: String? = nil
    }

    private struct Response: Codable {
        var message: String
    }

    public init() {
        session = NodePackage(name: "llm-chat-client").startJsonSession()
    }

    public func answer(input: String, on guildId: GuildID) async throws -> String? {
        try session.send(Request(message: input))
        let response = try await session.receive(Response.self)
        return response.message
    }
}
