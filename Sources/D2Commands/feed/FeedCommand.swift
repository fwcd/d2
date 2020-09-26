import Foundation
import FeedKit
import Dispatch
import D2Utils

public class FeedCommand<P>: StringCommand where P: FeedPresenter {
    public let info: CommandInfo
    private let presenter: P
    private let feedUrl: URL

    public init(feedUrl: String, description: String, presenter: P) {
        info = CommandInfo(
            category: .feed,
            shortDescription: description,
            requiredPermissionLevel: .basic
        )
        self.feedUrl = URL(string: feedUrl)!
        self.presenter = presenter
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        let parser = FeedParser(URL: feedUrl)

        Promise { then in parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated), result: then) }
            .listen {
                do {
                    let feed = try $0.get()
                    output.append(self.presenter.present(feed: feed))
                } catch {
                    output.append(error, errorText: "Could not fetch feed!")
                }
            }
    }
}
