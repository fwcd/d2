import Foundation
import D2MessageIO
import D2Commands
import D2Utils

fileprivate struct SpammerProfile {
    let lastSpamMessages = ExpiringList<Message>()
    var cautioned: Bool = false
}

/**
 * Automatically detects "mention-spammers" and assigns
 * them a spammer role (which can be configured using a command).
 */
struct SpamHandler: MessageHandler {
    private let config: AutoSerializing<SpamConfiguration>
    private let lastSpamMessages = ExpiringList<Message>()
    private var cautionedSpammers = Set<UserID>()
    
    init(config: AutoSerializing<SpamConfiguration>) {
        self.config = config
    }

    mutating func handle(message: Message, from client: MessageClient) -> Bool {
        guard isPossiblySpam(message: message) else { return false }
        lastSpamMessages.append(message, expiry: Date().addingTimeInterval(config.value.interval))
        
        guard let guild = client.guildForChannel(message.channelId) else { return false }
        let author = message.author.id

        if isSpamming(user: author) {
            if cautionedSpammers.contains(author) {
                client.sendMessage(Message(content: ":octagonal_sign: Penalizing <@\(author)> for spamming!"), to: message.channelId)
                penalize(spammer: author, on: guild, client: client)
            } else {
                client.sendMessage(Message(content: ":warning: Please stop spamming, <@\(author)>!"), to: message.channelId)
                cautionedSpammers.insert(author)
            }
        }

        return true
    }
    
    private func isPossiblySpam(message: Message) -> Bool {
        return message.mentions.count > 4 || message.mentionRoles.count > 1 || message.mentionEveryone
    }
    
    private func isSpamming(user: UserID) -> Bool {
        return lastSpamMessages.count(forWhich: { $0.author.id == user }) > config.value.maxSpamMessagesPerInterval
    }
    
    private func penalize(spammer user: UserID, on guild: Guild, client: MessageClient) {
        guard let member = guild.members[user] else { return }

        if let role = config.value.spammerRoles[guild.id] {
            add(role: role, to: user, on: guild, client: client) {
                if self.config.value.removeOtherRolesFromSpammer {
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
                print("Could not add role \(role) to spammer \(user)")
            }
        }
    }
    
    private func remove(roles: [RoleID], from user: UserID, on guild: Guild, client: MessageClient, then: (() -> Void)? = nil) {
        var remainingRoles = roles
        guard let role = remainingRoles.popLast() else {
            then?()
            return
        }

        client.removeGuildMemberRole(role, from: user, on: guild.id) { success, _ in
            if !success {
                print("Could not remove role \(role) from spammer \(user)")
            }
            self.remove(roles: remainingRoles, from: user, on: guild, client: client, then: then)
        }
    }
}
