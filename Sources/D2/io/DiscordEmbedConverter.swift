import D2MessageIO
import SwiftDiscord
import Foundation

// TO Discord conversions

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
		return DiscordEmbed.Field(name: name, value: value, inline: inline)
	}
}

// FROM Discord conversions

extension DiscordEmbed {
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
			fields: fields.map { $0.usingMessageIO }
		)
	}
}

extension DiscordEmbed.Author {
	var usingMessageIO: Embed.Author {
		return Embed.Author(
			name: name,
			iconUrl: iconUrl,
			url: url
		)
	}
}

extension DiscordEmbed.Thumbnail {
	var usingMessageIO: Embed.Thumbnail {
		return Embed.Thumbnail(url: url)
	}
}

extension DiscordEmbed.Image {
	var usingMessageIO: Embed.Image {
		return Embed.Image(url: url)
	}
}

extension DiscordEmbed.Footer {
	var usingMessageIO: Embed.Footer {
		return Embed.Footer(text: text)
	}
}

extension DiscordEmbed.Field {
	var usingMessageIO: Embed.Field {
		return Embed.Field(name: name, value: value, inline: inline)
	}
}
