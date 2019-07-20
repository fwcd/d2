import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension InteractiveTextChannel {
	public func send(_ message: String) {
		send(Message(content: message))
	}
	
	public func send(embed: DiscordEmbed) {
		send(Message(embed: embed))
	}
}

extension Guild {
	public var allUsers: [DiscordUser] { return members.map { $0.value.user } }
	
	public func users(with roles: [RoleID]) -> [DiscordUser] {
		return roles.flatMap { role in
			members
				.map { $0.value }
				.filter { $0.roleIds.contains(role) }
				.map { $0.user }
		}

extension Message {
	public var allMentionedUsers: [DiscordUser] {
		guard let guild = guildMember?.guild else { return [] }
		if mentionEveryone {
			return guild.allUsers
		} else {
			return mentions + guild.users(with: mentionRoles)
		}
	}
}

extension DiscordAttachment {
	/**
	 * Downloads the attachment asynchronously.
	 */
	public func download(then: @escaping (Result<Data, Error>) -> Void) {
		URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
			guard error == nil else {
				then(.failure(URLRequestError.ioError(error!)))
				return
			}
			guard let data = data else {
				then(.failure(URLRequestError.missingData))
				return
			}
			then(.success(data))
		}.resume()
	}
}
