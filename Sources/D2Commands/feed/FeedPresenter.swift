import FeedKit
import D2MessageIO

public protocol FeedPresenter {
    func present(feed: Feed) -> Embed?
}
