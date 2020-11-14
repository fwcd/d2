import Foundation
import FeedKit
import SwiftSoup
import D2MessageIO
import Utils

/// Presents only the most recent item as image.
public struct FeedImagePresenter: FeedPresenter {
    private let converter = DocumentToMarkdownConverter()

    public init() {}

    public func present(feed: Feed) throws -> Embed? {
        // TODO: Atom, ...
        switch feed {
            case .rss(let rss): return try present(rss: rss)
            default: return nil
        }
    }

    private func present(rss: RSSFeed) throws -> Embed? {
        // TODO: Produce proper error messages instead of just returning nil
        guard let item = rss.items?.first else { return nil }
        return Embed(
            title: item.title,
            url: item.link.flatMap(URL.init(string:)),
            image: try extractImageUrl(item: item, base: rss.link.flatMap(URL.init(string:)))
                .map(Embed.Image.init(url:))
        )
    }

    private func extractImageUrl(item: RSSFeedItem, base: URL? = nil) throws -> URL? {
        (try extractImageLinkFromEnclosure(item: item) ?? extractImageLinkFromHtml(item: item))
            .flatMap { absolutize(urlString: $0, against: base) }
    }

    private func extractImageLinkFromEnclosure(item: RSSFeedItem) -> String? {
        item.enclosure
            .flatMap(\.attributes)
            .filter { $0.type?.starts(with: "image/") ?? false }
            .flatMap(\.url)
    }

    private func extractImageLinkFromHtml(item: RSSFeedItem) throws -> String? {
        guard let description = item.description else { return nil }
        let document = try SwiftSoup.parseBodyFragment(description)
        guard let imgSrc = try document.getElementsByTag("img").array().first?.attr("src") else { return nil }
        return imgSrc
    }

    private func absolutize(urlString: String, against base: URL?) -> URL? {
        if urlString.starts(with: "/"), let base = base, let scheme = base.scheme, let host = base.host {
            return URL(string: "\(scheme)://\(host)\(urlString)")
        } else {
            return URL(string: urlString)
        }
    }
}
