import Foundation

public struct GiphyResults: Codable {
    public let data: [GIF]

    public struct GIF: Codable {
        // See https://developers.giphy.com/docs/api/schema/#gif-object

        public let type: String
        public let id: String
        public let slug: String
        public let url: URL

        // The direct GIF link
        public var downloadUrl: URL? { URL(string: "https://media.giphy.com/media/\(id)/giphy.gif") }
    }
}
