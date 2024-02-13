import Utils
import Foundation

extension InteractiveTextChannel {
    public func send(_ message: String) {
        send(Message(content: message))
    }

    public func send(embed: Embed) {
        send(Message(embed: embed))
    }
}

extension Guild {
    public var allUsers: [User] { return members.map { $0.1.user } }

    public func users(with roles: [RoleID]) -> [User] {
        return roles.flatMap { role in
            members
                .map { $0.1 }
                .filter { $0.roleIds.contains(role) }
                .map { $0.user }
        }
    }
}

extension Guild.Member {
    public var displayName: String { nick ?? user.username }
}

fileprivate let mentionPattern = try! LegacyRegex(from: "<@[&!]+(\\d+)>")
fileprivate let everyoneMentionPattern = try! LegacyRegex(from: "@(everyone|here)")

extension String {
    public func cleaningMentions(with guild: Guild? = nil) -> String {
        let mentionCleaned = mentionPattern.replace(in: self, using: {
            // TODO: This currently assumes Discord IDs
            let id = ID($0[1], clientName: "Discord")
            return guild?.members[id]?.displayName ?? guild?.roles[id]?.name ?? $0[1]
        } )
        let everyoneCleaned = everyoneMentionPattern.replace(in: mentionCleaned, using: {
            "@`\($0[1])`"
        })
        return everyoneCleaned
    }
}

extension Message {
    public var allMentionedUsers: [User] {
        if mentionEveryone {
            return guild?.allUsers ?? []
        } else {
            return mentions + (guild?.users(with: mentionRoles) ?? [])
        }
    }
    public var cleanContent: String { content.cleaningMentions(with: guild) }
    public var authorDisplayName: String { guildMember?.displayName ?? author?.username ?? "<unknown>" }

    public func mentions(user: User) -> Bool { allMentionedUsers.contains { user.id == $0.id } }
}

extension Message.Attachment {
    /// Downloads the attachment asynchronously.
    public func download() -> Promise<Data, any Error> {
        Promise.catchingThen {
            guard let url = url else { throw NetworkError.missingURL }
            return HTTPRequest(url: url).runAsync()
        }
    }
}
