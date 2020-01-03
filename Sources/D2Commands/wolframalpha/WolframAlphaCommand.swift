import SwiftDiscord
import Foundation
import D2Permissions
import D2NetAPIs
import D2Graphics
import D2Utils

fileprivate let flagPattern = try! Regex(from: "--(\\S+)")

public class WolframAlphaCommand: StringCommand {
	public let info = CommandInfo(
		category: .wolframalpha,
		shortDescription: "Queries Wolfram Alpha",
		longDescription: "Sets the permission level of one or more users",
		helpText: "[--image]? [--steps]? [query input]",
		requiredPermissionLevel: .vip
	)
	private var isRunning = false
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard !isRunning else {
			output.append("Wait for the first input to finish!")
			return
		}
		isRunning = true
		
		do {
			let flags = Set(flagPattern.allGroups(in: input).map { $0[1] })
			let processedInput = flagPattern.replace(in: input, with: "")
			
			if flags.contains("image") {
				// Performs a "simple" query and outputs a static image
				try performSimpleQuery(input: processedInput, output: output)
			} else {
				// Performs a full query and outputs an embed
				try performFullQuery(input: processedInput, output: output, showSteps: flags.contains("steps"))
			}
		} catch {
			output.append("An error occurred. Check the log for more information.")
		}
	}
	
	private func performSimpleQuery(input: String, output: CommandOutput) throws {
		let query = try WolframAlphaQuery(input: input, endpoint: .simpleQuery)
		query.start {
			guard case let .success(data) = $0 else {
				if case let .failure(error) = $0 { print(error) }
				output.append("An error occurred while querying WolframAlpha.")
				self.isRunning = false
				return
			}
			
			output.append(.files([DiscordFileUpload(data: data, filename: "wolframalpha.png", mimeType: "image/png")]))
			self.isRunning = false
		}
	}
	
	private func performFullQuery(input: String, output: CommandOutput, showSteps: Bool = false) throws {
		let query = try WolframAlphaQuery(input: input, endpoint: .fullQuery, showSteps: showSteps)
		query.startAndParse {
			guard case let .success(result) = $0 else {
				if case let .failure(error) = $0 { print(error) }
				output.append("An error occurred while querying WolframAlpha.")
				self.isRunning = false
				return
			}
			
			let images = result.pods.flatMap { pod in pod.subpods.compactMap { self.extractImageURL(from: $0) } }
			let plot = result.pods.filter { $0.title?.lowercased().contains("plot") ?? false }.first?.subpods.first.flatMap { self.extractImageURL(from: $0) }
			
			output.append(DiscordEmbed(
				title: "Query Output",
				author: DiscordEmbed.Author(name: "WolframAlpha", iconUrl: URL(string: "https://pbs.twimg.com/profile_images/804868917990739969/OFknlig__400x400.jpg")),
				image: (plot ?? images.last).map { DiscordEmbed.Image(url: $0) },
				thumbnail: images.first.map { DiscordEmbed.Thumbnail(url: $0) },
				color: 0xfdc81a,
				footer: DiscordEmbed.Footer(text: "success: \(result.success.map { String($0) } ?? "?"), error: \(result.error.map { String($0) } ?? "?"), timing: \(result.timing.map { String($0) } ?? "?")"),
				fields: result.pods.map { pod in DiscordEmbed.Field(
					// TODO: Investigate why Discord sends 400s for certain queries
					name: pod.title?.nilIfEmpty?.truncate(50, appending: "...") ?? "Untitled pod",
					value: pod.subpods.map { "\($0.title?.nilIfEmpty.map { "**\($0)** " } ?? "")\($0.plaintext ?? "")" }.joined(separator: "\n").truncate(1000, appending: "...")
						.trimmingCharacters(in: .whitespacesAndNewlines)
						.nilIfEmpty
						?? "No content"
				) }.truncate(6)
			))
			self.isRunning = false
		}
	}
	
	private func extractImageURL(from subpod: WolframAlphaSubpod) -> URL? {
		return (subpod.img?.src).flatMap { URL(string: $0) }
	}
}
