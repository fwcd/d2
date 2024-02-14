import Foundation
import Logging
import D2MessageIO
import D2NetAPIs
import D2Permissions
import Utils

public class RedditCommand<P>: StringCommand where P: RedditPresenter {
    public let info = CommandInfo(
        category: .forum,
        shortDescription: "Fetches a post from Reddit",
        longDescription: "Fetches a random top post from a given subreddit",
        presented: true,
        requiredPermissionLevel: .vip
    )
    private let presenter: P

    public init(presenter: P) {
        self.presenter = presenter
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Enter a subreddit to get started!")
            return
        }

        RedditQuery(subreddit: input, maxResults: 5).perform().listen {
            do {
                let links = try $0.get().data.children?.map(\.data) ?? []
                let embed = try self.presenter.present(links: links)
                output.append(embed)
            } catch {
                output.append(errorText: "Reddit search failed")
            }
        }
    }

    private func refersToImage(url: URL) -> Bool {
        let path = url.path
        return path.hasSuffix(".gif") || path.hasSuffix(".png") || path.hasSuffix(".jpg")
    }
}
