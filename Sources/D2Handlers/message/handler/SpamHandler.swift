import Foundation
import Logging
import D2MessageIO
import D2Commands
import D2Utils

fileprivate let log = Logger(label: "D2Handlers.SpamHandler")

fileprivate struct SpammerProfile {
    let lastSpamMessages = ExpiringList<Message>()
    var cautioned: Bool = false
}

/**
 * Automatically detects "mention-spammers" and assigns
 * them a spammer role (which can be configured using a command).
 */
public struct SpamHandler: MessageHandler {
    @AutoSerializing private var config: SpamConfiguration
    private let lastSpamMessages = ExpiringList<Message>()
    private var cautionedSpammers = Set<UserID>()
    
    public init(config: AutoSerializing<SpamConfiguration>) {
        self._config = config
    }

    public mutating func handle(message: Message, from client: MessageClient) -> Bool {
        guard isPossiblySpam(message: message) else { return false }
        lastSpamMessages.append(message, expiry: Date().addingTimeInterval(config.interval))
        
        guard let channelId = message.channelId,
            let guild = client.guildForChannel(channelId),
            let author = message.author?.id else { return false }

        if isSpamming(user: author) {
            if cautionedSpammers.contains(author) {
                client.sendMessage(Message(content: ":octagonal_sign: Penalizing <@\(author)> for spamming!"), to: channelId)
                penalize(spammer: author, on: guild, client: client)
            } else {
                client.sendMessage(Message(content: ":warning: Please stop spamming, <@\(author)>!"), to: channelId)
                cautionedSpammers.insert(author)
            }
        }

        return true
    }
    
    private func isPossiblySpam(message: Message) -> Bool {
        return message.mentions.count > 4 || message.mentionRoles.count > 1 || message.mentionEveryone
    }
    
    private func isSpamming(user: UserID) -> Bool {
        return lastSpamMessages.count(forWhich: { ($0.author?.id).map { id in id == user } ?? false }) > config.maxSpamMessagesPerInterval
    }
    
    private func penalize(spammer user: UserID, on guild: Guild, client: MessageClient) {
        guard let member = guild.members[user] else { return }

        if let role = config.spammerRoles[guild.id] {
            add(role: role, to: user, on: guild, client: client) {
                if self.config.removeOtherRolesFromSpammer {
                    self.remove(roles: member.roleIds, from: user, on: guild, client: client)
                }
            }
        }
    }
    
    private func add(role: RoleID, to user: UserID, on guild: Guild, client: MessageClient, then: (() -> Void)? = nil) {
        client.addGuildMemberRole(role, to: user, on: guild.id, reason: "Spamming") { success, _ in
            if success {
                then?()
            } else {
                log.warning("Could not add role \(role) to spammer \(user)")
            }
        }
    }
    
    private func remove(roles: [RoleID], from user: UserID, on guild: Guild, client: MessageClient, then: (() -> Void)? = nil) {
        var remainingRoles = roles
        guard let role = remainingRoles.popLast() else {
            then?()
            return
        }

        client.removeGuildMemberRole(role, from: user, on: guild.id, reason: "Spamming") { success, _ in
            if !success {
                log.warning("Could not remove role \(role) from spammer \(user)")
            }
            self.remove(roles: remainingRoles, from: user, on: guild, client: client, then: then)
        }
    }
}
