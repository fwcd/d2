import Foundation
@preconcurrency import FeedKit
import Dispatch
import Utils

public class FeedCommand<P>: VoidCommand where P: FeedPresenter {
    public let info: CommandInfo
    private let presenter: P
    private let url: URL

    public init(url: String, description: String, presenter: P) {
        info = CommandInfo(
            category: .feed,
            shortDescription: description,
            presented: true,
            requiredPermissionLevel: .basic
        )
        self.url = URL(string: url)!
        self.presenter = presenter
    }

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        do {
            let parser = FeedParser(URL: url)
            let feed = try await withCheckedThrowingContinuation { continuation in
                parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { @Sendable in
                    continuation.resume(with: $0)
                }
            }
            guard let embed = try self.presenter.present(feed: feed) else {
                await output.append(errorText: "Could not present feed")
                return
            }

            await output.append(embed)
        } catch {
            await output.append(error, errorText: "Could not fetch feed!")
        }
    }
}
