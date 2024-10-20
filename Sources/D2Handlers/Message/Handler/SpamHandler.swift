import Foundation
import Logging
import D2MessageIO
import D2Commands
import Utils

private let log = Logger(label: "D2Handlers.SpamHandler")

private struct SpammerProfile {
    let lastSpamMessages = ExpiringList<Message>()
    var cautioned: Bool = false
}

/// Automatically detects "mention-spammers" and assigns
/// them a spammer role (which can be configured using a command).
public struct SpamHandler: MessageHandler {
    @Binding private var config: SpamConfiguration
    private let dateProvider: @CommandActor () -> Date
    private let lastSpamMessages: ExpiringList<Message>
    private var cautionedSpammers = Set<UserID>()

    public init(@Binding config: SpamConfiguration, dateProvider: @CommandActor @escaping () -> Date = Date.init) {
        self._config = _config
        self.dateProvider = dateProvider
        lastSpamMessages = ExpiringList(dateProvider: dateProvider)
    }

    public mutating func handle(message: Message, sink: any Sink) async -> Bool {
        guard
            isPossiblySpam(message: message),
            let author = message.author,
            let channelId = message.channelId,
            let guild = await sink.guildForChannel(channelId),
            let daysOnGuild = guild.members[author.id].map({ Int(-$0.joinedAt.timeIntervalSinceNow / 86400) }),
            let limits = config.limitsByDaysOnGuild.filter({ daysOnGuild >= $0.key }).max(by: ascendingComparator(comparing: \.key))?.value else { return false }

        lastSpamMessages.append(message, expiry: (message.timestamp ?? dateProvider()).addingTimeInterval(limits.interval))

        if isSpamming(userId: author.id, limits: limits) {
            do {
                if cautionedSpammers.contains(author.id) {
                    try await sink.sendMessage(Message(content: ":octagonal_sign: Penalizing <@\(author.id)> for spamming!"), to: channelId)
                    try await penalize(spammer: author.id, on: guild, sink: sink)
                } else {
                    try await sink.sendMessage(Message(content: ":warning: Please stop spamming, <@\(author.id)>!"), to: channelId)
                    cautionedSpammers.insert(author.id)
                }
                return true
            } catch {
                log.warning("Could not send caution message for spamming: \(error)")
            }
        }

        return false
    }

    private func isPossiblySpam(message: Message) -> Bool {
        message.mentions.count >= 4 || message.mentionRoles.count >= 2 || message.mentionEveryone
    }

    private func isSpamming(userId: UserID, limits: SpamConfiguration.Limits) -> Bool {
        lastSpamMessages.count(forWhich: { ($0.author?.id).map { id in id == userId } ?? false }) > limits.maxSpamMessagesPerInterval
    }

    private func penalize(spammer user: UserID, on guild: Guild, sink: any Sink) async throws {
        guard let member = guild.members[user] else { return }

        if let role = config.spammerRoles[guild.id] {
            try await add(role: role, to: user, on: guild, sink: sink)
            if self.config.removeOtherRolesFromSpammer {
                try await remove(roles: member.roleIds, from: user, on: guild, sink: sink)
            }
        }
    }

    private func add(role: RoleID, to user: UserID, on guild: Guild, sink: any Sink) async throws {
        do {
            try await sink.addGuildMemberRole(role, to: user, on: guild.id, reason: "Spamming")
        } catch {
            log.warning("Could not add role \(role) to spammer \(user)")
        }
    }

    private func remove(roles: [RoleID], from user: UserID, on guild: Guild, sink: any Sink) async throws {
        for role in roles {
            do {
                try await sink.removeGuildMemberRole(role, from: user, on: guild.id, reason: "Spamming")
            } catch {
                log.warning("Could not remove role \(role) from spammer \(user): \(error)")
            }
        }
    }
}
