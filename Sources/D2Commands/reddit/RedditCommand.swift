import Foundation
import Logging
import SwiftDiscord
import D2NetAPIs
import D2Permissions
import D2Utils

public class RedditCommand: StringCommand {
	public let info = CommandInfo(
		category: .reddit,
		shortDescription: "Fetches a post from Reddit",
		longDescription: "Fetches a random top post from a given subreddit",
		requiredPermissionLevel: .vip
	)
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		RedditQuery(subreddit: input, maxResults: 10).perform {
			output.append($0.flatMap { Result.from($0.data.children?.randomElement()?.data, errorIfNil: RedditError.noResultsFound) }.map {
				RichValue.embed(DiscordEmbed(
					title: $0.title,
					description: $0.selftext,
					image: $0.url
						.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".png") || $0.hasSuffix(".gif") }
						.flatMap(URL.init(string:))
						.map(DiscordEmbed.Image.init(url:)),
					footer: DiscordEmbed.Footer(text: "\($0.ups ?? -1) upvotes, \($0.downs ?? -1) downvotes")
				))
			}, errorText: "Reddit search failed")
		}
	}
}
