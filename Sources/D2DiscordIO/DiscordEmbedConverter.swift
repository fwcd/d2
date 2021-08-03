import D2MessageIO
import Discord
import Foundation

// TO Discord conversions

extension Embed: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordEmbed {
        DiscordEmbed(
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
    public var usingDiscordAPI: DiscordEmbed.Author {
        DiscordEmbed.Author(
            name: name,
            iconUrl: iconUrl,
            url: url
        )
    }
}

extension Embed.Thumbnail: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordEmbed.Thumbnail {
        DiscordEmbed.Thumbnail(url: url)
    }
}

extension Embed.Image: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordEmbed.Image {
        DiscordEmbed.Image(url: url)
    }
}

extension Embed.Footer: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordEmbed.Footer {
        DiscordEmbed.Footer(text: text)
    }
}

extension Embed.Field: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordEmbed.Field {
        DiscordEmbed.Field(name: name, value: value, inline: inline)
    }
}

// FROM Discord conversions

extension DiscordEmbed: MessageIOConvertible {
    public var usingMessageIO: Embed {
        Embed(
            title: title,
            description: description,
            author: author?.usingMessageIO,
            url: url,
            image: image?.usingMessageIO,
            timestamp: timestamp,
            thumbnail: thumbnail?.usingMessageIO,
            color: color,
            footer: footer?.usingMessageIO,
            fields: fields?.usingMessageIO ?? []
        )
    }
}

extension DiscordEmbed.Author: MessageIOConvertible {
    public var usingMessageIO: Embed.Author {
        Embed.Author(
            name: name,
            iconUrl: iconUrl,
            url: url
        )
    }
}

extension DiscordEmbed.Thumbnail: MessageIOConvertible {
    public var usingMessageIO: Embed.Thumbnail {
        Embed.Thumbnail(url: url)
    }
}

extension DiscordEmbed.Image: MessageIOConvertible {
    public var usingMessageIO: Embed.Image {
        Embed.Image(url: url)
    }
}

extension DiscordEmbed.Footer: MessageIOConvertible {
    public var usingMessageIO: Embed.Footer {
        Embed.Footer(text: text)
    }
}

extension DiscordEmbed.Field: MessageIOConvertible {
    public var usingMessageIO: Embed.Field {
        Embed.Field(name: name, value: value, inline: inline)
    }
}
