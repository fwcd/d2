import Sword

enum DiscordMessageKey: String {
	case content = "content"
	case username = "username"
	case avatarUrl = "avatar_url"
	case tts = "tts"
	case file = "file"
	case embed = "embed"
}

extension TextChannel {
	func send(_ message: [DiscordMessageKey : Any], then completion: ((Message?, RequestError?) -> ())? = nil) {
		var newMessage = [String : Any]()
		
		for entry in message {
			newMessage[entry.key.rawValue] = entry.value
		}
		
		send(newMessage, then: completion)
	}
}
