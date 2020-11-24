import Foundation
import D2MessageIO
import D2NetAPIs

public struct RedditFeedPresenter: RedditPresenter {
    public init() {}

    public func present(links: [RedditLink]) throws -> Embed {
        Embed(
            title: "Subreddit Feed",
            thumbnail: (links.first?.url)
                .flatMap(URL.init(string:))
                .filter(self.refersToImage(url:))
                .map(Embed.Thumbnail.init(url:)),
            fields: links.map(self.present(link:))
        )
    }

    private func present(link: RedditLink) -> Embed.Field {
        Embed.Field(
            name: link.title ?? link.permalink ?? "<untitled post>",
            value: [link.selftext, link.ups.map { "\($0) \("upvote".pluralized(with: $0))" }]
                .compactMap { $0 }
                .joined(separator: "\n")
                .nilIfEmpty
                ?? "_no description_"
            // url: link.permalink.flatMap { URL(string: "https://www.reddit.com\($0)") },
        )
    }

    private func refersToImage(url: URL) -> Bool {
        let path = url.path
        return path.hasSuffix(".gif") || path.hasSuffix(".png") || path.hasSuffix(".jpg")
    }
}
