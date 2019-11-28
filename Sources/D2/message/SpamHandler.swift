import SwiftDiscord
import D2Commands
import D2Utils

/**
 * Automatically detects "mention-spammers" and assigns
 * them a spammer role (which can be configured using a command).
 */
struct SpamHandler: MessageHandler {
    private let config: SpamConfiguration
    
    init(config: SpamConfiguration) {
        self.config = config
    }

    func handle(message: DiscordMessage, from client: DiscordClient) -> Bool {
        // TODO
        return false
    }
    
    private func isSpamming(_ user: UserID) -> Bool {
        // TODO
        return false
    }
    
    private func cautionSpammer(_ user: UserID, channel: ChannelID, client: DiscordClient) {
        client.sendMessage(DiscordMessage(content: ":warning: Please stop spamming, <@\(user)>!"), to: channel)
    }
    
    private func penalizeSpammer(_ user: UserID, on guild: DiscordGuild, client: DiscordClient) {
        guard let member = guild.members[user] else { return }

        if let role = config.spammerRole {
            add(role: role, to: user, on: guild, client: client) {
                if self.config.removeOtherRolesFromSpammer {
                    self.remove(roles: member.roleIds, from: user, on: guild, client: client)
                }
            }
        }
    }
    
    private func add(role: RoleID, to user: UserID, on guild: DiscordGuild, client: DiscordClient, then: (() -> Void)? = nil) {
        client.addGuildMemberRole(role, to: user, on: guild.id, reason: "Spamming") { success, _ in
            if success {
                then?()
            } else {
                print("Could not add role \(role) to spammer \(user)")
            }
        }
    }
    
    private func remove(roles: [RoleID], from user: UserID, on guild: DiscordGuild, client: DiscordClient, then: (() -> Void)? = nil) {
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
