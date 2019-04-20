import SwiftDiscord
import Foundation
import D2Permissions
import D2WebAPIs

public class WolframAlphaCommand: StringCommand {
	public let description = "Queries Wolfram Alpha"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let query = try WolframAlphaQuery(input: input)
			query.start {
				guard case let .success(result) = $0 else {
					output.append("An error occurred while querying WolframAlpha.")
					return
				}
				
				result.pods.map { pod in print(pod.subpods.map { "\($0.title?.nilIfEmpty.map { "**\($0)**\n" } ?? "")\($0.plaintext ?? "")" }.joined(separator: "\n").truncate(1000, appending: "...")) }
				output.append(DiscordEmbed(
					title: "Query Output",
					author: DiscordEmbed.Author(name: "WolframAlpha", iconUrl: URL(string: "https://pbs.twimg.com/profile_images/804868917990739969/OFknlig__400x400.jpg")),
					thumbnail: (result.pods.first?.subpods.first?.img?.src).flatMap { URL(string: $0) }.map { DiscordEmbed.Thumbnail(url: $0) },
					color: 0xfdc81a,
					footer: DiscordEmbed.Footer(text: "success: \(result.success.map { String($0) } ?? "?"), error: \(result.error.map { String($0) } ?? "?"), timing: \(result.timing.map { String($0) } ?? "?")"),
					fields: result.pods.map { pod in DiscordEmbed.Field(
						name: pod.title?.truncate(100, appending: "...") ?? "Untitled pod",
						value: pod.subpods.map { "\($0.title?.nilIfEmpty.map { "**\($0)**\n" } ?? "")\($0.plaintext ?? "")" }.joined(separator: "\n").truncate(1000, appending: "...") ?? ""
					) }.truncate(5)
				))
			}
		} catch {
			output.append("An error occurred. Check the log for more information.")
		}
	}
}
