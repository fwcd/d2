import D2Commands
import D2MessageIO
import D2Utils

public struct GreetingHandler: MessageHandler {
    private let greetings: Set<String>

    public init(greetings: Set<String> = ["hello"]) {
        self.greetings = greetings
    }

    public func handle(message: Message, from client: MessageClient) -> Bool {
        if greetings.contains(message.content.lowercased()), let messageId = message.id, let channelId = message.channelId {
            client.createReaction(for: messageId, on: channelId, emoji: "👋")
            return true
        }
        return false
    }
}
