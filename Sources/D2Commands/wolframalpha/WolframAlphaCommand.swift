import SwiftDiscord
import Foundation
import D2Permissions
import D2WebAPIs
import D2Graphics
import D2Utils

fileprivate let flagPattern = try! Regex(from: "--(\\S+)")

public class WolframAlphaCommand: StringCommand {
	public let description = "Queries Wolfram Alpha"
	public let helpText = "[--image]? [query input]"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let flags = Set(flagPattern.allGroups(in: input).map { $0[1] })
			let processedInput = flagPattern.replace(in: input, with: "")
			
			if flags.contains("image") {
				// Performs a "simple" query and outputs a static image
				try performSimpleQuery(input: processedInput, output: output)
			} else {
				// Performs a full query and outputs an embed
				try performFullQuery(input: processedInput, output: output)
			}
		} catch {
			output.append("An error occurred. Check the log for more information.")
		}
	}
	
	private func performSimpleQuery(input: String, output: CommandOutput) throws {
		let query = try WolframAlphaSimpleQuery(input: input)
		query.start {
			guard case let .success(data) = $0 else {
				output.append("An error occurred while querying WolframAlpha.")
				return
			}
			
			output.append(DiscordMessage(
				content: "",
				files: [DiscordFileUpload(data: data, filename: "wolframalpha.png", mimeType: "image/png")]
			))
		}
	}
	
	private func performFullQuery(input: String, output: CommandOutput) throws {
		let query = try WolframAlphaFullQuery(input: input)
		query.start {
			guard case let .success(result) = $0 else {
				output.append("An error occurred while querying WolframAlpha.")
				return
			}
			
			output.append(DiscordEmbed(
				title: "Query Output",
				author: DiscordEmbed.Author(name: "WolframAlpha", iconUrl: URL(string: "https://pbs.twimg.com/profile_images/804868917990739969/OFknlig__400x400.jpg")),
				thumbnail: (result.pods.first?.subpods.first?.img?.src).flatMap { URL(string: $0) }.map { DiscordEmbed.Thumbnail(url: $0) },
				color: 0xfdc81a,
				footer: DiscordEmbed.Footer(text: "success: \(result.success.map { String($0) } ?? "?"), error: \(result.error.map { String($0) } ?? "?"), timing: \(result.timing.map { String($0) } ?? "?")"),
				fields: result.pods.map { pod in DiscordEmbed.Field(
					// TODO: Investigate why Discord sends 400s for certain queries
					name: pod.title?.nilIfEmpty?.truncate(50, appending: "...") ?? "Untitled pod",
					value: pod.subpods.map { "\($0.title?.nilIfEmpty.map { "**\($0)** " } ?? "")\($0.plaintext ?? "")" }.joined(separator: "\n").truncate(500, appending: "...")
						.trimmingCharacters(in: .whitespacesAndNewlines)
						.nilIfEmpty
						?? "No content"
				) }.truncate(10)
			))
		}
	}
}
