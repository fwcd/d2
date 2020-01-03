import SwiftDiscord
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension DiscordTextChannel {
	public func send(_ message: String) {
		send(DiscordMessage(content: message))
	}
	
	public func send(embed: DiscordEmbed) {
		send(DiscordMessage(fromEmbed: embed))
	}
}

extension DiscordGuild {
	public var allUsers: [DiscordUser] { return members.map { $0.value.user } }
	
	public func users(with roles: [RoleID]) -> [DiscordUser] {
		return roles.flatMap { role in
			members
				.map { $0.value }
				.filter { $0.roleIds.contains(role) }
				.map { $0.user }
		}
	}
}

extension DiscordMessage {
	public var allMentionedUsers: [DiscordUser] {
		guard let guild = guildMember?.guild else { return [] }
		if mentionEveryone {
			return guild.allUsers
		} else {
			return mentions + guild.users(with: mentionRoles)
		}
	}
}

extension DiscordMessageLikeInitializable {
	public init(fromContent content: String) {
		self.init(content: content, embed: nil, files: [], tts: false)
	}
	
	public init(fromEmbed embed: DiscordEmbed?) {
		self.init(content: "", embed: embed, files: [], tts: false)
	}
	
	public init(fromFiles files: [DiscordFileUpload]) {
		self.init(content: "", embed: nil, files: files, tts: false)
	}
}

extension DiscordAttachment {
	/**
	 * Downloads the attachment asynchronously.
	 */
	public func download(then: @escaping (Result<Data, Error>) -> Void) {
		URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
			guard error == nil else {
				then(.failure(NetworkError.ioError(error!)))
				return
			}
			guard let data = data else {
				then(.failure(NetworkError.missingData))
				return
			}
			then(.success(data))
		}.resume()
	}
}
