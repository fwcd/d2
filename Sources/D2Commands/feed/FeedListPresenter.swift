import FeedKit
import D2MessageIO

public struct FeedListPresenter: FeedPresenter {
    public init() {}

    public func present(feed: Feed) -> Embed? {
        // TODO: Atom, ...
        switch feed {
            case .rss(let rss): return present(rss: rss)
            default: return nil
        }
    }

    private func present(rss: RSSFeed) -> Embed {
        Embed(
            title: rss.title,
            description: rss.description,
            fields: rss.items?.prefix(5).compactMap {
                guard let title = $0.title else { return nil }
                return Embed.Field(name: title, value: $0.description ?? "_no description_")
            } ?? []
        )
    }
}
