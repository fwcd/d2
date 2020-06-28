import D2MessageIO
import D2Utils

fileprivate let inventoryCategory = "Discordinder Matches"
fileprivate let acceptEmoji = "✅"
fileprivate let rejectEmoji = "❌"

public class DiscordinderCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Play a matching game with other people on the server!",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true
    )
    private let inventoryManager: InventoryManager
    
    public init(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let authorId = context.author?.id else {
            output.append(errorText: "Author has no user ID")
            return
        }
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild!")
            return
        }
        guard let channelId = context.channel?.id else {
            output.append(errorText: "No channel ID")
            return
        }
        guard let client = context.client else {
            output.append(errorText: "No client")
            return
        }

        let nonCandidateIds: Set<UserID> = Set(matches(for: authorId)
            .filter { $0.state != .waitingForAcceptor || $0.initiator.id != authorId }
            .flatMap { [$0.initiator.id, $0.acceptor.id] })
        let candidates: [Guild.Member] = guild.members
            .filter { !nonCandidateIds.contains($0.0) }
            .map { $0.1 }
        
        guard let candidate = candidates.randomElement() else {
            output.append(errorText: "Sorry, no candidates are left!")
            return
        }

        client.sendMessage(Message(content: candidate.displayName), to: channelId) { sentMessage, _ in
            guard let messageId = sentMessage?.id else { return }
            context.subscribeToChannel()

            let reactions = [rejectEmoji, acceptEmoji]
            collect(thenables: reactions.map { emoji in
                { then in client.createReaction(for: messageId, on: channelId, emoji: emoji) { _, _ in then(.success(())) } }
            }) { _ in }
        }
    }

	public func onSubscriptionReaction(emoji: Emoji, by user: User, output: CommandOutput, context: CommandContext) {
    }

    /** Fetches all (including rejected or awaiting) matches for a user. */
    private func matches(for userId: UserID) -> [DiscordinderMatch] {
        return inventoryManager[userId].items[inventoryCategory]?.compactMap { $0.asDiscordinderMatch } ?? []
    }

    /** Initiates or accepts a match between two users. */
    private func accept(matchBetween firstId: UserID, and secondId: UserID) {
        // TODO
    }

    /** Rejects a match between two users. */
    private func reject(matchBetween firstId: UserID, and secondId: UserID) {
        // TODO
    }
}
