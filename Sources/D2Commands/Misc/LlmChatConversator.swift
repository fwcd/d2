import Logging
import Utils
import D2MessageIO

fileprivate let log = Logger(label: "D2Commands.LlmChatConversator")

public actor LlmChatConversator: Conversator {
    private let session: NodePackage.JsonSession
    private let systemPrompt: String
    private var isAnswering = false

    private struct Request: Codable {
        enum CodingKeys: String, CodingKey {
            case message
            case systemMessage = "system_message"
        }

        var message: String
        var systemMessage: String? = nil
    }

    private struct Response: Codable {
        var message: String
    }

    public init(
        systemPrompt: String = """
            You are a language model operating in the context of a Discord bot,
            a virtual assistant named "D2". Provide brief, friendly and useful
            answers.
            """
    ) throws {
        session = try NodePackage(name: "llm-chat-client").startJsonSession()
        self.systemPrompt = systemPrompt
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
        let request = Request(message: input, systemMessage: systemPrompt)
        try session.send(request)

        let response = try await session.receive(Response.self)
        let answer = response.message
        log.info("Got \(answer)")

        return answer
    }
}
