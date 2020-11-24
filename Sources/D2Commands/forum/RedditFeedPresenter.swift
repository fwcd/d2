import Foundation
import D2MessageIO
import D2NetAPIs

public struct RedditFeedPresenter: RedditPresenter {
    public init() {}

    public func present(links: [RedditLink]) throws -> Embed {
        Embed(
            title: "Subreddit Feed",
            description: links
                .map(self.present(link:))
                .joined(separator: "\n")
                .nilIfEmpty
                ?? "_none_",
            thumbnail: (links.first?.url)
                .flatMap(URL.init(string:))
                .filter(self.refersToImage(url:))
                .map(Embed.Thumbnail.init(url:))
        )
    }

    private func present(link: RedditLink) -> String {
        let title = link.title ?? "<untitled post>"
        return [
            "**\(link.permalink.map { "[\(title)](https://www.reddit.com\($0))" } ?? title)**",
            link.selftext,
            link.ups.map { "\($0) \("upvote".pluralized(with: $0))" }
        ].compactMap { $0 }.joined(separator: "\n")
    }

    private func refersToImage(url: URL) -> Bool {
        let path = url.path
        return path.hasSuffix(".gif") || path.hasSuffix(".png") || path.hasSuffix(".jpg")
    }
}
