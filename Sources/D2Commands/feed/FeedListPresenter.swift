import FeedKit
import D2MessageIO
import D2Utils

public struct FeedListPresenter: FeedPresenter {
    private let itemCount: Int
    private let converter = DocumentToMarkdownConverter()

    public init(itemCount: Int = 4) {
        self.itemCount = itemCount
    }

    public func present(feed: Feed) throws -> Embed? {
        // TODO: Atom, ...
        switch feed {
            case .rss(let rss): return try present(rss: rss)
            default: return nil
        }
    }

    private func present(rss: RSSFeed) throws -> Embed {
        try Embed(
            title: rss.title,
            description: rss.description,
            fields: rss.items?.prefix(itemCount).compactMap {
                guard let title = $0.title else { return nil }
                return try Embed.Field(
                    name: title,
                    value: $0.description.map { try converter.convert(htmlFragment: $0) } ?? "_no description_"
                )
            } ?? []
        )
    }
}
