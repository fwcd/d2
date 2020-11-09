import Dispatch
import D2Commands
import D2MessageIO
import Utils

fileprivate let mentionPattern = try! Regex(from: "<@.+?>")

public struct MentionD2Handler: MessageHandler {
    private let conversator: Conversator
    private let queue = DispatchQueue(label: "MentionD2Handler", qos: .background)

    public init(conversator: Conversator) {
        self.conversator = conversator
    }

    public func handleRaw(message: Message, from client: MessageClient) -> Bool {
        if let me = client.me,
            !message.mentionEveryone,
            message.mentions(user: me),
            let messageId = message.id,
            let guild = message.guild,
            let channelId = message.channelId {
            queue.async {
                if let answer = try? conversator.answer(input: mentionPattern.replace(in: message.content, with: ""), on: guild.id) {
                    client.sendMessage(Message(content: answer.cleaningMentions(with: guild)), to: channelId)
                } else {
                    client.createReaction(for: messageId, on: channelId, emoji: "🤔")
                }
            }
            return true
        }
        return false
    }
}
