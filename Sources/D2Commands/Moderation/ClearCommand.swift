import D2MessageIO
import Utils
import Logging

private let log = Logger(label: "D2Commands.ClearCommand")
private let confirmationString = "delete"

public class ClearCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Clears messages",
        longDescription: "Removes the last n messages",
        requiredPermissionLevel: .mod,
        subscribesToNextMessages: true
    )
    private let minDeletableCount: Int
    private let maxDeletableCount: Int
    private let finalConfirmationDeletionSeconds: Double
    private var preparedDeletions: [ChannelID: [Deletion]] = [:]
    private var finallyConfirmed: Set<ChannelID> = []

    private struct Deletion {
        let message: Message
        let isIntended: Bool // Whether this was NOT a confirmational message during the deletion process
    }

    public init(minDeletableCount: Int = 1, maxDeletableCount: Int = 80, finalConfirmationDeletionSeconds: Double = 2) {
        self.minDeletableCount = minDeletableCount
        self.maxDeletableCount = maxDeletableCount
        self.finalConfirmationDeletionSeconds = finalConfirmationDeletionSeconds
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let sink = context.sink else {
            await output.append(errorText: "No MessageIO client available")
            return
        }
        guard let n = Int(input), n >= minDeletableCount, n <= maxDeletableCount else {
            await output.append(errorText: "Please enter a number (of messages to be deleted) between \(minDeletableCount) and \(maxDeletableCount)!")
            return
        }
        guard let channelId = context.message.channelId else {
            await output.append(errorText: "Message has no channel ID")
            return
        }

        do {
            let messages = try await sink.getMessages(for: channelId, limit: n + 1)
            let deletions = messages.map { Deletion(message: $0, isIntended: $0.id != context.message.id) }
            let intended = deletions.filter { $0.isIntended }.map { $0.message }

            self.preparedDeletions[channelId] = deletions
            let grouped = Dictionary(grouping: intended, by: { $0.author?.username ?? "<unnamed>" })

            await output.append(Embed(
                title: ":warning: You are about to DELETE \(intended.count) \("message".pluralized(with: intended.count))",
                description: """
                    \(grouped.map { "\($0.1.count) \("message".pluralized(with: $0.1.count)) by \($0.0)" }.joined(separator: "\n").nilIfEmpty ?? "_none_")

                    Are you sure? Enter `\(confirmationString)` to confirm (any other message will cancel).
                    """
            ))
            context.subscribeToChannel()
        } catch {
            await output.append(error, errorText: "Could not get messages")
        }
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async {
        if let sink = context.sink, let channel = context.channel, let deletions = preparedDeletions[channel.id].map({ $0 + [Deletion(message: context.message, isIntended: false)] }) {
            let intendedDeletionCount = deletions.filter { $0.isIntended }.count
            let confirmationDeletionCount = deletions.count - intendedDeletionCount
            preparedDeletions[channel.id] = nil

            if content == confirmationString {
                log.notice("Deleting \(intendedDeletionCount) \("message".pluralized(with: intendedDeletionCount)) and \(confirmationDeletionCount) \("confirmation".pluralized(with: confirmationDeletionCount))")
                if deletions.count == 1, let messageId = deletions.first?.message.id {
                    do {
                        try await sink.deleteMessage(messageId, on: channel.id)
                        self.finallyConfirmed.insert(channel.id)
                        await output.append(":wastebasket: Deleted message")
                    } catch {
                        await output.append(error, errorText: "Could not delete message")
                    }
                } else {
                    let messageIds = deletions.compactMap { $0.message.id }
                    guard !messageIds.isEmpty else {
                        await output.append(errorText: "No messages to be deleted have an ID, this is most likely a bug.")
                        return
                    }
                    do {
                        try await sink.bulkDeleteMessages(messageIds, on: channel.id)
                        self.finallyConfirmed.insert(channel.id)
                        await output.append(":wastebasket: Deleted \(intendedDeletionCount) messages (+ some confirmations)")
                    } catch {
                        await output.append(error, errorText: "Could not delete messages")
                    }
                }
            } else {
                await output.append(":x: Cancelling deletion")
            }
        }

        context.unsubscribeFromChannel()
    }

    public func onSuccessfullySent(context: CommandContext) async {
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
            guard let sink = context.sink else {
                log.warning("No client available for deleting the final confirmation message")
                return
            }

            // Automatically delete the final confirmation message after some time
            do {
                try await Task.sleep(for: .seconds(finalConfirmationDeletionSeconds))
                try await sink.deleteMessage(messageId, on: channelId)
            } catch {
                log.warning("Could not delete final confirmation message: \(error)")
            }
        }
    }
}
