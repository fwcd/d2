import Foundation
import Logging
import D2MessageIO
import D2NetAPIs
import D2Permissions
import D2Utils

public class RedditCommand: StringCommand {
	public let info = CommandInfo(
		category: .forum,
		shortDescription: "Fetches a post from Reddit",
		longDescription: "Fetches a random top post from a given subreddit",
		requiredPermissionLevel: .vip
	)

	public init() {}

	public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
		RedditQuery(subreddit: input, maxResults: 40).perform().listen {
			output.append($0.flatMap { Result.from($0.data.children?.randomElement()?.data, errorIfNil: RedditError.noResultsFound) }.map {
				RichValue.embed(Embed(
					title: $0.title,
					description: $0.selftext,
					url: $0.permalink.flatMap { URL(string: "https://www.reddit.com\($0)") },
					image: ($0.preview?.firstGif?.source?.url ?? $0.url)
						.flatMap(URL.init(string:))
						.filter(self.refersToImage(url:))
						.map(Embed.Image.init(url:)),
					footer: Embed.Footer(text: "\($0.ups ?? -1) upvotes, \($0.downs ?? -1) downvotes")
				))
			}, errorText: "Reddit search failed")
		}
	}

	private func refersToImage(url: URL) -> Bool {
		let path = url.path
		return path.hasSuffix(".gif") || path.hasSuffix(".png") || path.hasSuffix(".jpg")
	}
}
