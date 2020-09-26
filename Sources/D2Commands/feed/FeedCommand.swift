import Foundation
import FeedKit
import Dispatch
import D2Utils

public class FeedCommand<P>: StringCommand where P: FeedPresenter {
    public let info: CommandInfo
    private let presenter: P
    private let url: URL

    public init(url: String, description: String, presenter: P) {
        info = CommandInfo(
            category: .feed,
            shortDescription: description,
            requiredPermissionLevel: .basic
        )
        self.url = URL(string: url)!
        self.presenter = presenter
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        let parser = FeedParser(URL: url)

        Promise { then in parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated), result: then) }
            .listen {
                do {
                    let feed = try $0.get()
                    guard let embed = try self.presenter.present(feed: feed) else {
                        output.append(errorText: "Could not present feed")
                        return
                    }

                    output.append(embed)
                } catch {
                    output.append(error, errorText: "Could not fetch feed!")
                }
            }
    }
}
