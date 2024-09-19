import Utils
import D2MessageIO

public actor LlmChatConversator: Conversator {
    private let session: NodePackage.JsonSession
    private var isAnswering = false

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
        // Since actors are reentrant, we need to guard against interleaving answer
        // requests. Our solution is to simply make them return `nil`.
        guard !isAnswering else { return nil }
        isAnswering = true
        defer { isAnswering = false }

        try session.send(Request(message: input))
        let response = try await session.receive(Response.self)
        return response.message
    }
}
