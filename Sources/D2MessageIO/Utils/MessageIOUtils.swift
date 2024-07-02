import Utils
import Foundation

extension InteractiveTextChannel {
    public func send(_ message: String) async throws {
        try await send(Message(content: message))
    }

    public func send(embed: Embed) async throws {
        try await send(Message(embed: embed))
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

fileprivate let mentionPattern = #/<@[&!]+(?<id>\d+)>/#
fileprivate let everyoneMentionPattern = #/@(?<target>everyone|here)/#

extension String {
    public func cleaningMentions(with guild: Guild? = nil) -> String {
        let mentionCleaned = replacing(mentionPattern) {
            // TODO: This currently assumes Discord IDs
            let id = ID(String($0.id), clientName: "Discord")
            return guild?.members[id]?.displayName ?? guild?.roles[id]?.name ?? String($0.id)
        }
        let everyoneCleaned = mentionCleaned.replacing(everyoneMentionPattern) {
            "@`\($0.target)`"
        }
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
