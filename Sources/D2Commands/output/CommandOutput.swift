import SwiftDiscord
import D2Utils

public protocol CommandOutput {
	func append(_ message: DiscordMessage)
}

extension CommandOutput {
	public func append(_ str: String) {
		append(DiscordMessage(content: str))
	}
	
	public func append(_ embed: DiscordEmbed) {
		append(DiscordMessage(fromEmbed: embed))
	}
	
	public func append(_ image: Image) throws {
		append(try DiscordMessage(fromImage: image))
	}
}
