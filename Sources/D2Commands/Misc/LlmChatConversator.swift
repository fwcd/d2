import Logging
import Utils
import D2MessageIO

fileprivate let log = Logger(label: "D2Commands.LlmChatConversator")

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

    public init() throws {
        session = try NodePackage(name: "llm-chat-client").startJsonSession()
    }

    public func answer(input: String, on guildId: GuildID) async throws -> String? {
        // Since actors are reentrant, we need to guard against interleaving answer
        // requests. Our solution is to simply make them return `nil`.
        guard !isAnswering else {
            log.warning("Ignoring '\(input)' since the LLM has not responded yet...")
            return nil
        }
        isAnswering = true
        defer { isAnswering = false }

        log.info("Answering '\(input)' via LLM...")
        let request = Request(message: input)
        try session.send(request)

        let response = try await session.receive(Response.self)
        let answer = response.message
        log.info("Got \(answer)")

        return answer
    }
}
