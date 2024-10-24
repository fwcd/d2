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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Enter a subreddit to get started!")
            return
        }

        do {
            let thing = try await RedditQuery(subreddit: input, maxResults: 5).perform()
            let links = thing.data.children?.map(\.data) ?? []
            let embed = try self.presenter.present(links: links)
            await output.append(embed)
        } catch {
            await output.append(errorText: "Reddit search failed")
        }
    }

    private func refersToImage(url: URL) -> Bool {
        let path = url.path
        return path.hasSuffix(".gif") || path.hasSuffix(".png") || path.hasSuffix(".jpg")
    }
}
