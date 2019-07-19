import D2MessageIO
import SwiftDiscord
import Foundation

extension Embed {
	var usingDiscordAPI: DiscordEmbed {
		return DiscordEmbed(
			title: title,
			description: description,
			author: author?.usingDiscordAPI,
			url: url,
			image: image?.usingDiscordAPI,
			timestamp: timestamp,
			thumbnail: thumbnail?.usingDiscordAPI,
			color: color,
			footer: footer?.usingDiscordAPI,
			fields: fields.map { $0.usingDiscordAPI }
		)
	}
}

extension Embed.Author {
	var usingDiscordAPI: DiscordEmbed.Author {
		return DiscordEmbed.Author(
			name: name,
			iconUrl: iconUrl,
			url: url
		)
	}
}

extension Embed.Thumbnail {
	var usingDiscordAPI: DiscordEmbed.Thumbnail {
		return DiscordEmbed.Thumbnail(url: url)
	}
}

extension Embed.Image {
	var usingDiscordAPI: DiscordEmbed.Image {
		return DiscordEmbed.Image(url: url)
	}
}

extension Embed.Footer {
	var usingDiscordAPI: DiscordEmbed.Footer {
		return DiscordEmbed.Footer(text: text)
	}
}

extension Embed.Field {
	var usingDiscordAPI: DiscordEmbed.Field {
		return DiscordEmbed.Field(name: name, value: value)
	}
}
