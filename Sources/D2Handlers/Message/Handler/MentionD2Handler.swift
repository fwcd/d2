import Dispatch
import D2Commands
import D2MessageIO
import Logging
import Utils

fileprivate let mentionPattern = #/<@.+?>/#
fileprivate let log = Logger(label: "D2Handlers.MentionD2Handler")

public struct MentionD2Handler<C>: MessageHandler where C: Conversator {
    private let conversator: C

    public init(conversator: C) {
        self.conversator = conversator
    }

    public func handleRaw(message: Message, sink: any Sink) async -> Bool {
        if let me = sink.me,
            !message.mentionEveryone,
            message.mentions(user: me),
            let messageId = message.id,
            let guild = message.guild,
            let channelId = message.channelId {
            if let answer = try? await conversator.answer(input: message.content.replacing(mentionPattern, with: ""), on: guild.id) {
                Task {
                    do {
                        try await sink.sendMessage(Message(content: answer.cleaningMentions(with: guild)), to: channelId)
                    } catch {
                        log.warning("Could not send reply to D2 mention: \(error)")
                    }
                }
            } else {
                Task {
                    do {
                        try await sink.createReaction(for: messageId, on: channelId, emoji: "🤔")
                    } catch {
                        log.warning("Could not react to D2 mention: \(error)")
                    }
                }
            }
            return true
        }
        return false
    }
}
