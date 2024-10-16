import Foundation
@preconcurrency import FeedKit
import D2MessageIO
import Utils

nonisolated(unsafe) private let newlinesPattern = #/[\r\n]+/#

/// Presents the n most recent items as a list.
public struct FeedListPresenter: FeedPresenter {
    private let itemCount: Int
    private let converter = DocumentToMarkdownConverter()

    public init(itemCount: Int = 4) {
        self.itemCount = itemCount
    }

    public func present(feed: Feed) throws -> Embed? {
        // TODO: Atom, ...
        switch feed {
            case .rss(let rss): try present(rss: rss)
            default: nil
        }
    }

    private func present(rss: RSSFeed) throws -> Embed {
        try Embed(
            title: rss.title,
            description: rss.items?.prefix(itemCount).compactMap {
                guard let title = $0.title, let link = $0.link else { return nil }
                return """
                    **[\(title)](\(link))**
                    \(try $0.description
                        .map { try converter.convert(htmlFragment: $0).replacing(newlinesPattern, with: "\n") }?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .truncated(to: 300, appending: "...")
                        ?? "_no description_")
                    """
            }.joined(separator: "\n"),
            thumbnail: rss.image?.url.flatMap(URL.init(string:)).map(Embed.Thumbnail.init(url:))
        )
    }
}
