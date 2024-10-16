import Foundation
import D2MessageIO
import Utils

fileprivate let inventoryCategory = "Discordinder Matches"
fileprivate let cancelSubcommand = "cancel"
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
    private var activeMatches: [MessageID: (ChannelID, UserID)] = [:]

    public init(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if input == cancelSubcommand {
            guard context.isSubscribed else {
                await output.append(errorText: "No session is running on this channel!")
                return
            }

            cancelSession(context: context)
            await output.append(":x: Cancelled Discordinder session on this channel!")
        } else {
            guard let authorId = context.author?.id else {
                await output.append(errorText: "Author has no user ID")
                return
            }
            guard !context.isSubscribed else {
                await output.append(errorText: "There is already an active session on this channel!")
                return
            }

            await presentNextCandidate(for: authorId, output: output, context: context)
        }
    }

    public func onSubscriptionReaction(emoji: Emoji, by user: User, output: any CommandOutput, context: CommandContext) async {
        guard
            let guild = context.guild,
            let messageId = context.message.id,
            let (_, candidateId) = activeMatches[messageId] else { return }

        switch emoji.name {
            case rejectEmoji:
                reject(matchBetween: user.id, and: candidateId, on: guild)
            case acceptEmoji:
                let state = accept(matchBetween: user.id, and: candidateId, on: guild)
                if state == .accepted {
                    await output.append(":partying_face: It's a match!")
                    cancelSession(context: context)
                    return
                }
            case ignoreEmoji:
                takeMatch(between: user.id, and: candidateId, on: guild)
            default:
                break
        }

        activeMatches[messageId] = nil
        let success = await presentNextCandidate(for: user.id, output: output, context: context)
        if !success {
            context.unsubscribeFromChannel()
        }
    }

    @discardableResult
    private func presentNextCandidate(for authorId: UserID, output: any CommandOutput, context: CommandContext) async -> Bool {
        guard let guild = context.guild else {
            await output.append(errorText: "Not on a guild!")
            return false
        }
        guard let sink = context.sink else {
            await output.append(errorText: "No client")
            return false
        }
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "No channel ID")
            return false
        }

        let authorMatches = matches(for: authorId)
        var waitingForAcceptor: Set<UserID> = Set(authorMatches
            .filter { ($0.state == .waitingForAcceptor && $0.initiator.id != authorId) || ($0.state == .waitingForInitiator && $0.initiator.id == authorId) }
            .map { $0.initiator.id })
        var nonCandidateIds: Set<UserID> = Set(authorMatches
            .flatMap { [$0.initiator.id, $0.acceptor.id] })
            .filter { !waitingForAcceptor.contains($0) }

        waitingForAcceptor.remove(authorId)
        nonCandidateIds.insert(authorId)

        guard let candidateId = waitingForAcceptor.randomElement() ?? guild.members.filter({ !nonCandidateIds.contains($0.0) && !$0.1.user.bot }).randomElement()?.0 else {
            await output.append(errorText: "Sorry, no candidates are left!")
            return false
        }
        guard let candidate = guild.members[candidateId] else {
            await output.append(errorText: "Could not find candidate")
            return false
        }
        let candidatePresence = guild.presences[candidateId]

        do {
            let sentMessage = try await sink.sendMessage(Message(embed: embedOf(member: candidate, presence: candidatePresence, sink: sink)), to: channelId)
            if let messageId = sentMessage?.id {
                context.subscribeToChannel()
                self.accept(matchBetween: authorId, and: candidateId, on: guild)
                self.activeMatches[messageId] = (channelId, candidateId)

                let reactions = [rejectEmoji, ignoreEmoji, acceptEmoji]
                for reaction in reactions {
                    try await sink.createReaction(for: messageId, on: channelId, emoji: reaction)
                }
            } else {
                await output.append(errorText: "Sent message has no id")
            }
        } catch {
            await output.append(error, errorText: "Could not send message/create reaction for next candidate")
        }

        return true
    }

    private func cancelSession(context: CommandContext) {
        guard let channelId = context.channel?.id else { return }
        activeMatches = activeMatches.filter { (c, _) in channelId != c }
        context.unsubscribeFromChannel()
    }

    private func embedOf(member: Guild.Member, presence: Presence?, sink: any Sink) async -> Embed {
        Embed(
            title: member.displayName,
            description: (presence?.activities.first).map { descriptionOf(activity: $0) },
            image: await sink.avatarUrlForUser(member.user.id, with: member.user.avatar, size: 256).map(Embed.Image.init)
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
            case .game: "play"
            case .stream: "stream"
            case .listening: "listen to"
            default: "do"
        }
    }

    /// Fetches all (including rejected or awaiting) matches for a user.
    private func matches(for userId: UserID) -> [DiscordinderMatch] {
        return inventoryManager[userId].items[inventoryCategory]?.compactMap { $0.asDiscordinderMatch } ?? []
    }

    @discardableResult
    private func takeMatch(between firstId: UserID, and secondId: UserID, on guild: Guild) -> DiscordinderMatch {
        guard
            let firstMember = guild.members[firstId],
            let secondMember = guild.members[secondId] else { fatalError("User IDs for match not on the specified guild!") }
        var firstInventory = inventoryManager[firstId]
        var secondInventory = inventoryManager[secondId]
        let matching: [(DiscordinderMatch, Inventory.Item)] = ((firstInventory.items[inventoryCategory] ?? []) + (secondInventory.items[inventoryCategory] ?? [])).compactMap({
            guard
                let match = $0.asDiscordinderMatch,
                Set([match.initiator.id, match.acceptor.id]) == [firstId, secondId] else { return nil }
            return (match, $0)
        })

        if let (match, item) = matching.first {
            firstInventory.remove(item: item, from: inventoryCategory)
            secondInventory.remove(item: item, from: inventoryCategory)

            inventoryManager[firstId] = firstInventory
            inventoryManager[secondId] = secondInventory

            return match
        } else {
            return DiscordinderMatch(
                initiator: .init(id: firstId, name: firstMember.displayName),
                acceptor: .init(id: secondId, name: secondMember.displayName),
                state: .waitingForCreation
            )
        }
    }

    private func setMatch(between firstId: UserID, and secondId: UserID, to match: DiscordinderMatch) {
        var firstInventory = inventoryManager[firstId]
        var secondInventory = inventoryManager[secondId]

        let item = Inventory.Item(fromDiscordinderMatch: match)
        firstInventory.remove(item: item, from: inventoryCategory)
        secondInventory.remove(item: item, from: inventoryCategory)
        firstInventory.append(item: item, to: inventoryCategory)
        secondInventory.append(item: item, to: inventoryCategory)

        inventoryManager[firstId] = firstInventory
        inventoryManager[secondId] = secondInventory
    }

    /// Initiates or accepts a match between two users.
    @discardableResult
    private func accept(matchBetween firstId: UserID, and secondId: UserID, on guild: Guild) -> DiscordinderMatch.MatchState {
        let match = takeMatch(between: firstId, and: secondId, on: guild).accepted
        setMatch(between: firstId, and: secondId, to: match)
        return match.state
    }

    /// Rejects a match between two users.
    @discardableResult
    private func reject(matchBetween firstId: UserID, and secondId: UserID, on guild: Guild) -> DiscordinderMatch.MatchState {
        let match = takeMatch(between: firstId, and: secondId, on: guild).rejected
        setMatch(between: firstId, and: secondId, to: match)
        return match.state
    }
}
