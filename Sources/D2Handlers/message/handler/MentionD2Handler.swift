import D2Commands
import D2MessageIO
import D2Utils

fileprivate let mentionPattern = try! Regex(from: "<@.+?>")

public struct MentionD2Handler: MessageHandler {
    private let conversator: Conversator

    public init(conversator: Conversator) {
        self.conversator = conversator
    }

    public func handleRaw(message: Message, from client: MessageClient) -> Bool {
        if let me = client.me,
            message.mentions(user: me),
            let messageId = message.id,
            let guildId = message.guild?.id,
            let channelId = message.channelId {
            if let answer = try? conversator.answer(input: mentionPattern.replace(in: message.content, with: ""), on: guildId) {
                client.sendMessage(Message(content: answer), to: channelId)
            } else {
                client.createReaction(for: messageId, on: channelId, emoji: "🤔")
            }
            return true
        }
        return false
    }
}
