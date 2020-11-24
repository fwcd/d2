import D2NetAPIs
import D2MessageIO

public protocol RedditPresenter {
    func present(links: [RedditLink]) throws -> Embed?
}
