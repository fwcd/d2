import FeedKit

public protocol FeedPresenter {
    func present(feed: Feed) -> RichValue
}
