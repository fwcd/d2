import Foundation
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

        let authorMatches = matches(for: authorId)
        let waitingForAcceptor: Set<UserID> = Set(authorMatches
            .filter { $0.state == .waitingForAcceptor && $0.initiator.id != authorId }
            .map { $0.initiator.id })
        let nonCandidateIds: Set<UserID> = Set(authorMatches
            .flatMap { [$0.initiator.id, $0.acceptor.id] })
            .filter { !waitingForAcceptor.contains($0) }
        
        guard let candidateId = waitingForAcceptor.randomElement() ?? guild.members.keys.filter({ !nonCandidateIds.contains($0) }).randomElement() else {
            output.append(errorText: "Sorry, no candidates are left!")
            return
        }
        guard let candidate = guild.members[candidateId] else {
            output.append(errorText: "Could not find candidate")
            return
        }
        let candidatePresence = guild.presences[candidateId]

        client.sendMessage(Message(embed: embedOf(member: candidate, presence: candidatePresence)), to: channelId) { sentMessage, _ in
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

    private func embedOf(member: Guild.Member, presence: Presence?) -> Embed {
        Embed(
            title: member.displayName,
            description: (presence?.game).map { descriptionOf(activity: $0) },
            image: URL(string: "https://cdn.discordapp.com/avatars/\(member.user.id)/\(member.user.avatar).png?size=256").map(Embed.Image.init)
        )
    }

    private func descriptionOf(activity: Presence.Activity) -> String {
        var detail: String = "Likes to \(verbOf(activityType: activity.type)) \(activity.name)"
        if activity.name == "Custom Status", let state = activity.state {
            detail = state
        }
        return detail
    }

    private func verbOf(activityType: Presence.Activity.ActivityType) -> String {
        switch activityType {
            case .game: return "play"
            case .stream: return "stream"
            case .listening: return "listen to"
        }
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
