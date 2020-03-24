import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension InteractiveTextChannel {
	public func send(_ message: String) {
		send(Message(content: message))
	}
	
	public func send(embed: Embed) {
		send(Message(embed: embed))
	}
}

extension Guild {
	public var allUsers: [User] { return members.map { $0.value.user } }
	
	public func users(with roles: [RoleID]) -> [User] {
		return roles.flatMap { role in
			members
				.map { $0.value }
				.filter { $0.roleIds.contains(role) }
				.map { $0.user }
		}
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
}

extension Message.Attachment {
	/**
	 * Downloads the attachment asynchronously.
	 */
	public func download(then: @escaping (Result<Data, Error>) -> Void) {
		guard let url = url else {
			then(.failure(URLRequestError.missingURL))
			return
		}
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
