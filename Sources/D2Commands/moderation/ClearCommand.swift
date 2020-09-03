import D2MessageIO
import D2Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.ClearCommand")
fileprivate let confirmationString = "delete"

public class ClearCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Clears messages",
        longDescription: "Removes the last n messages",
        requiredPermissionLevel: .vip,
        subscribesToNextMessages: true
    )
    private let minDeletableCount: Int
    private let maxDeletableCount: Int
    private let finalConfirmationDeletionTimer: RepeatingTimer
    private var preparedDeletions: [ChannelID: [Deletion]] = [:]
    private var finallyConfirmed: Set<ChannelID> = []

    private struct Deletion {
        let message: Message
        let isIntended: Bool // Whether this was NOT a confirmational message during the deletion process
    }

    public init(minDeletableCount: Int = 1, maxDeletableCount: Int = 80, finalConfirmationDeletionSeconds: Int = 2) {
        self.minDeletableCount = minDeletableCount
        self.maxDeletableCount = maxDeletableCount
        finalConfirmationDeletionTimer = RepeatingTimer(interval: .seconds(finalConfirmationDeletionSeconds))
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
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

        client.getMessages(for: channelId, limit: n + 1).listenOrLogError { messages in
            let deletions = messages.map { Deletion(message: $0, isIntended: $0.id != context.message.id) }
            let intended = deletions.filter { $0.isIntended }.map { $0.message }

            self.preparedDeletions[channelId] = deletions
            let grouped = Dictionary(grouping: intended, by: { $0.author?.username ?? "<unnamed>" })

            output.append(Embed(
                title: ":warning: You are about to DELETE \(intended.count) \("message".pluralize(with: intended.count))",
                description: """
                    \(grouped.map { "\($0.1.count) \("message".pluralize(with: $0.1.count)) by \($0.0)" }.joined(separator: "\n").nilIfEmpty ?? "_none_")

                    Are you sure? Enter `\(confirmationString)` to confirm (any other message will cancel).
                    """
            ))
        }
        context.subscribeToChannel()
    }

    public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {
        if let client = context.client, let channel = context.channel, let deletions = preparedDeletions[channel.id].map({ $0 + [Deletion(message: context.message, isIntended: false)] }) {
            let intendedDeletionCount = deletions.filter { $0.isIntended }.count
            let confirmationDeletionCount = deletions.count - intendedDeletionCount
            preparedDeletions[channel.id] = nil

            if content == confirmationString {
                log.notice("Deleting \(intendedDeletionCount) \("message".pluralize(with: intendedDeletionCount)) and \(confirmationDeletionCount) \("confirmation".pluralize(with: confirmationDeletionCount))")
                if deletions.count == 1, let messageId = deletions.first?.message.id {
                    client.deleteMessage(messageId, on: channel.id).listenOrLogError { success in
                        if success {
                            self.finallyConfirmed.insert(channel.id)
                            output.append(":wastebasket: Deleted message")
                        } else {
                            output.append(errorText: "Could not delete message")
                        }
                    }
                } else {
                    let messageIds = deletions.compactMap { $0.message.id }
                    guard !messageIds.isEmpty else {
                        output.append(errorText: "No messages to be deleted have an ID, this is most likely a bug.")
                        return
                    }
                    client.bulkDeleteMessages(messageIds, on: channel.id).listenOrLogError { success in
                        if success {
                            self.finallyConfirmed.insert(channel.id)
                            output.append(":wastebasket: Deleted \(intendedDeletionCount) messages (+ some confirmations)")
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

    public func onSuccessfullySent(context: CommandContext) {
        let message = context.message
        log.debug("Successfully sent \(message)")
        guard let channelId = message.channelId else {
            log.warning("No channel ID for message after being sent. This is most likely a bug.")
            return
        }
        if preparedDeletions[channelId] != nil {
            // While preparing a deletion, memorize all messages
            preparedDeletions[channelId]!.append(Deletion(message: message, isIntended: false))
        } else if let messageId = message.id, finallyConfirmed.remove(channelId) != nil {
            guard let client = context.client else {
                log.warning("No client available for deleting the final confirmation message")
                return
            }

            // Automatically delete the final confirmation message after some time
            finalConfirmationDeletionTimer.schedule(beginImmediately: false) { _, _ in
                client.deleteMessage(messageId, on: channelId)
            }
        }
    }
}
