import Foundation

public struct DesignQuote: Sendable, Codable {
    public let title: RenderedText
    public let content: RenderedText
    public let excerpt: RenderedText?
    public let link: URL?
    public let date: String?
    public let type: String?
    public let status: String?

    public struct RenderedText: Sendable, Codable {
        public let rendered: String
        public let protected: Bool?
    }
}
