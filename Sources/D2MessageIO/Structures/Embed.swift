import Foundation

public struct Embed: Sendable, Codable {
    public var title: String?
    public var description: String?
    public var author: Author?
    public var url: URL?
    public var image: Image?
    public var timestamp: Date?
    public var thumbnail: Thumbnail?
    public var color: Int?
    public var footer: Footer?
    public var fields: [Field]

    public init(
        title: String? = nil,
        description: String? = nil,
        author: Author? = nil,
        url: URL? = nil,
        image: Image? = nil,
        timestamp: Date? = nil,
        thumbnail: Thumbnail? = nil,
        color: Int? = nil,
        footer: Footer? = nil,
        fields: [Field] = []
    ) {
        self.title = title
        self.description = description
        self.author = author
        self.url = url
        self.image = image
        self.timestamp = timestamp
        self.thumbnail = thumbnail
        self.color = color
        self.footer = footer
        self.fields = fields
    }

    public struct Author: Sendable, Codable {
        public let name: String
        public let iconUrl: URL?
        public let url: URL?

        public init(name: String, iconUrl: URL? = nil, url: URL? = nil) {
            self.name = name
            self.iconUrl = iconUrl
            self.url = url
        }
    }

    public struct Image: Sendable, Codable {
        public let url: URL

        public init(url: URL) {
            self.url = url
        }
    }

    public struct Thumbnail: Sendable, Codable {
        public let url: URL

        public init(url: URL) {
            self.url = url
        }
    }

    public struct Footer: Sendable, Codable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
        public let text: String?

        public init(text: String? = nil) {
            self.text = text
        }

        public init(stringLiteral value: String) {
            self.init(text: value)
        }
    }

    public struct Field: Sendable, Codable {
        public var name: String
        public var value: String
        public var inline: Bool

        public init(name: String, value: String, inline: Bool = false) {
            self.name = name
            self.value = value
            self.inline = inline
        }
    }
}
