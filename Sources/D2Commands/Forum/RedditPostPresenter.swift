import Foundation
import D2MessageIO
import D2NetAPIs

public struct RedditPostPresenter: RedditPresenter {
    public init() {}

    public func present(links: [RedditLink]) throws -> Embed {
        guard let link = links.first else { throw RedditError.noResultsFound }
        return present(link: link)
    }

    private func present(link: RedditLink) -> Embed {
        Embed(
            title: link.title,
            description: link.selftext,
            url: link.permalink.flatMap { URL(string: "https://www.reddit.com\($0)") },
            image: (link.preview?.firstGif?.source?.url ?? link.url)
                .flatMap(URL.init(string:))
                .filter(self.refersToImage(url:))
                .map(Embed.Image.init(url:)),
            footer: "\(link.ups ?? 0) upvotes"
        )
    }

    private func refersToImage(url: URL) -> Bool {
        let path = url.path
        return path.hasSuffix(".gif") || path.hasSuffix(".png") || path.hasSuffix(".jpg")
    }
}
