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
				
				output.append(DiscordEmbed(
					title: "Query Output",
					author: DiscordEmbed.Author(name: "WolframAlpha", iconUrl: URL(string: "https://pbs.twimg.com/profile_images/804868917990739969/OFknlig__400x400.jpg")),
					image: (result.pods.first?.subpods.first?.img?.src).flatMap { URL(string: $0) }.map { DiscordEmbed.Image(url: $0) },
					footer: DiscordEmbed.Footer(text: "success: \(result.success), error: \(result.error)"),
					fields: result.pods.map { pod in DiscordEmbed.Field(
						name: pod.title ?? "Untitled pod",
						value: pod.subpods.map { "**\($0.title ?? "Untitled subpod")**\n\($0.plaintext ?? "")" }.joined(separator: "\n")
					) }
				))
			}
		} catch {
			output.append("An error occurred. Check the log for more information.")
		}
	}
}
