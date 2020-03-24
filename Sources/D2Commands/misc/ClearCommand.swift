import SwiftDiscord
import Logging

fileprivate let log = Logger(label: "ClearCommand")
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
    private var messagesToBeDeleted: [ChannelID: [DiscordMessage]] = [:]
    
    public init(minDeletableCount: Int = 1, maxDeletableCount: Int = 80) {
        self.minDeletableCount = minDeletableCount
        self.maxDeletableCount = maxDeletableCount
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let client = context.client else {
            output.append("No DiscordClient available")
            return
        }
        guard let n = Int(input), n >= minDeletableCount, n <= maxDeletableCount else {
            output.append("Please enter a number (of messages to be deleted) between \(minDeletableCount) and \(maxDeletableCount)!")
            return
        }
        
        let channelId = context.message.channelId
        client.getMessages(for: channelId, limit: n) { messages, _ in
            self.messagesToBeDeleted[channelId] = messages
            let grouped = Dictionary(grouping: messages, by: { $0.author.username })

            output.append(DiscordEmbed(
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
                if messages.count == 1 {
                    client.deleteMessage(messages[0].id, on: channel.id) { success, _ in
                        if success {
                            output.append(":wastebasket: Deleted message")
                        } else {
                            output.append(errorText: "Could not delete message")
                        }
                    }
                } else {
                    client.bulkDeleteMessages(messages.map { $0.id }, on: channel.id) { success, _ in
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
    
    public func onSuccessfullySent(message: DiscordMessage) {
        log.debug("Successfully sent \(message)")
        let channelId = message.channelId
        if messagesToBeDeleted[channelId] != nil {
            messagesToBeDeleted[channelId]!.append(message)
        }
    }
}
