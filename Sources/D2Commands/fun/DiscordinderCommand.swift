import Foundation
import D2MessageIO
import D2Utils

fileprivate let inventoryCategory = "Discordinder Matches"
fileprivate let acceptEmoji = "✅"
fileprivate let ignoreEmoji = "🟨"
fileprivate let rejectEmoji = "❌"

public class DiscordinderCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Play a matching game with other people on the server!",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true
    )
    private let inventoryManager: InventoryManager
    private var activeMatches: [MessageID: UserID] = [:]
    
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
            self.accept(matchBetween: authorId, and: candidateId, on: guild)
            self.activeMatches[messageId] = candidateId

            let reactions = [rejectEmoji, ignoreEmoji, acceptEmoji]
            for reaction in reactions {
                client.createReaction(for: messageId, on: channelId, emoji: reaction)
            }
        }
    }

	public func onSubscriptionReaction(emoji: Emoji, by user: User, output: CommandOutput, context: CommandContext) {
        guard let messageId = context.message.id, let candidateId = activeMatches[messageId], let guild = context.guild else { return }

        switch emoji.name {
            case rejectEmoji:
                reject(matchBetween: user.id, and: candidateId, on: guild)
                output.append("Rejected `\(user.username)`.")
            case acceptEmoji:
                let state = accept(matchBetween: user.id, and: candidateId, on: guild)
                switch state {
                    case .waitingForAcceptor:
                        output.append(":hourglass: Waiting for `\(user.username)`.")
                    case .accepted:
                        output.append(":partying_face: It's a match!")
                    default:
                        output.append(errorText: "Invalid accept state: \(state)")
                }
            default:
                output.append("Ignoring `\(user.username)`.")
        }

        activeMatches[messageId] = nil
        context.unsubscribeFromChannel()
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

    private func getMatch(between firstId: UserID, and secondId: UserID, on guild: Guild) -> DiscordinderMatch {
        guard let firstMember = guild.members[firstId], let secondMember = guild.members[secondId] else { fatalError("User IDs for match not on the specified guild!") }
        return (inventoryManager[firstId].items.flatMap { $0.value } + inventoryManager[secondId].items.flatMap { $0.value })
            .compactMap { $0.asDiscordinderMatch }
            .first
            ?? DiscordinderMatch(
                initiator: .init(id: firstId, name: firstMember.displayName),
                acceptor: .init(id: secondId, name: secondMember.displayName),
                state: .waitingForInitiator
            )
    }

    private func setMatch(between firstId: UserID, and secondId: UserID, to match: DiscordinderMatch) {
        var firstInventory = inventoryManager[firstId]
        var secondInventory = inventoryManager[secondId]

        let item = Inventory.Item(fromDiscordinderMatch: match)
        firstInventory.append(item: item, to: inventoryCategory)
        secondInventory.append(item: item, to: inventoryCategory)

        inventoryManager[firstId] = firstInventory
        inventoryManager[secondId] = secondInventory
    }

    /** Initiates or accepts a match between two users. */
    @discardableResult
    private func accept(matchBetween firstId: UserID, and secondId: UserID, on guild: Guild) -> DiscordinderMatch.MatchState {
        let match = getMatch(between: firstId, and: secondId, on: guild).accepted
        setMatch(between: firstId, and: secondId, to: match)
        return match.state
    }

    /** Rejects a match between two users. */
    @discardableResult
    private func reject(matchBetween firstId: UserID, and secondId: UserID, on guild: Guild) -> DiscordinderMatch.MatchState {
        let match = getMatch(between: firstId, and: secondId, on: guild).rejected
        setMatch(between: firstId, and: secondId, to: match)
        return match.state
    }
}
