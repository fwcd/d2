import SwiftDiscord

public protocol DiscordMessageLikeInitializable {
	init(content: String, embed: DiscordEmbed?, files: [DiscordFileUpload], tts: Bool)
}

extension DiscordMessage: DiscordMessageLikeInitializable {}
