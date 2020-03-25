import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Commands.ClearCommand")
fileprivate let confirmationString = "delete"

public class ClearCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Clears messages",
        longDescription: "Removes the last n messages",
        requiredPermissionLevel: .admin,
        subscribesToNextMessages: true
    )
    private let minDeletableCount: Int
    private let maxDeletableCount: Int
    private var messagesToBeDeleted: [ChannelID: [Message]] = [:]
    
    public init(minDeletableCount: Int = 1, maxDeletableCount: Int = 80) {
        self.minDeletableCount = minDeletableCount
        self.maxDeletableCount = maxDeletableCount
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let client = context.client else {
            output.append(errorText: "No MessageIO client available")
            return
        }
        guard let n = Int(input), n >= minDeletableCount, n <= maxDeletableCount else {
            output.append(errorText: "Please enter a number (of messages to be deleted) between \(minDeletableCount) and \(maxDeletableCount)!")
            return
        }
        guard let channelId = context.message.channelId else {
            output.append(errorText: "Message has no channel ID")
            return
        }

        client.getMessages(for: channelId, limit: n) { messages, _ in
            self.messagesToBeDeleted[channelId] = messages
            let grouped = Dictionary(grouping: messages, by: { $0.author?.username ?? "<unnamed>" })

            output.append(Embed(
                title: ":warning: You are about to DELETE \(messages.count) \("message".pluralize(with: messages.count))",
                description: """
                    \(grouped.map { "\($0.1.count) \("message".pluralize(with: $0.1.count)) by \($0.0)" }.joined(separator: "\n").nilIfEmpty ?? "_none_")
                    
                    Are you sure? Enter `\(confirmationString)` to confirm (any other message will cancel).
                    """
            ))
        }
        context.subscribeToChannel()
    }
    
    public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {
        if let client = context.client, let channel = context.channel, let messages = messagesToBeDeleted[channel.id] {
            messagesToBeDeleted[channel.id] = nil
            if content == confirmationString {
                log.notice("Deleting \(messages.count) \("message".pluralize(with: messages.count))")
                if messages.count == 1, let messageId = messages.first?.id {
                    client.deleteMessage(messageId, on: channel.id) { success, _ in
                        if success {
                            output.append(":wastebasket: Deleted message")
                        } else {
                            output.append(errorText: "Could not delete message")
                        }
                    }
                } else {
                    let messageIds = messages.compactMap { $0.id }
                    guard !messageIds.isEmpty else {
                        output.append(errorText: "No messages to be deleted have an ID, this is most likely a bug.")
                        return
                    }
                    client.bulkDeleteMessages(messageIds, on: channel.id) { success, _ in
                        if success {
                            output.append(":wastebasket: Deleted \(messages.count) messages")
                        } else {
                            output.append(errorText: "Could not delete messages")
                        }
                    }
                }
            } else {
                output.append(":x: Cancelling deletion")
            }
        }
        context.unsubscribeFromChannel()
    }
    
    public func onSuccessfullySent(message: Message) {
        log.debug("Successfully sent \(message)")
        guard let channelId = message.channelId else {
            log.warning("No channel ID for message after being sent. This is most likely a bug.")
            return
        }
        if messagesToBeDeleted[channelId] != nil {
            messagesToBeDeleted[channelId]!.append(message)
        }
    }
}
