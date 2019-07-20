import D2MessageIO
import SwiftDiscord
import Foundation

// TO Discord conversions

extension Embed: DiscordAPIConvertible {
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
			fields: fields.usingDiscordAPI
		)
	}
}

extension Embed.Author: DiscordAPIConvertible {
	var usingDiscordAPI: DiscordEmbed.Author {
		return DiscordEmbed.Author(
			name: name,
			iconUrl: iconUrl,
			url: url
		)
	}
}

extension Embed.Thumbnail: DiscordAPIConvertible {
	var usingDiscordAPI: DiscordEmbed.Thumbnail {
		return DiscordEmbed.Thumbnail(url: url)
	}
}

extension Embed.Image: DiscordAPIConvertible {
	var usingDiscordAPI: DiscordEmbed.Image {
		return DiscordEmbed.Image(url: url)
	}
}

extension Embed.Footer: DiscordAPIConvertible {
	var usingDiscordAPI: DiscordEmbed.Footer {
		return DiscordEmbed.Footer(text: text)
	}
}

extension Embed.Field: DiscordAPIConvertible {
	var usingDiscordAPI: DiscordEmbed.Field {
		return DiscordEmbed.Field(name: name, value: value, inline: inline)
	}
}

// FROM Discord conversions

extension DiscordEmbed: MessageIOConvertible {
	var usingMessageIO: Embed {
		return Embed(
			title: title,
			description: description,
			author: author?.usingMessageIO,
			url: url,
			image: image?.usingMessageIO,
			timestamp: timestamp,
			thumbnail: thumbnail?.usingMessageIO,
			color: color,
			footer: footer?.usingMessageIO,
			fields: fields.usingMessageIO
		)
	}
}

extension DiscordEmbed.Author: MessageIOConvertible {
	var usingMessageIO: Embed.Author {
		return Embed.Author(
			name: name,
			iconUrl: iconUrl,
			url: url
		)
	}
}

extension DiscordEmbed.Thumbnail: MessageIOConvertible {
	var usingMessageIO: Embed.Thumbnail {
		return Embed.Thumbnail(url: url)
	}
}

extension DiscordEmbed.Image: MessageIOConvertible {
	var usingMessageIO: Embed.Image {
		return Embed.Image(url: url)
	}
}

extension DiscordEmbed.Footer: MessageIOConvertible {
	var usingMessageIO: Embed.Footer {
		return Embed.Footer(text: text)
	}
}

extension DiscordEmbed.Field: MessageIOConvertible {
	var usingMessageIO: Embed.Field {
		return Embed.Field(name: name, value: value, inline: inline)
	}
}
