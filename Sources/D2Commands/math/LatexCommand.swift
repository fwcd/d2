import SwiftDiscord
import Logging
import D2Permissions
import D2Utils

fileprivate let log = Logger(label: "LatexCommand")
fileprivate let flagPattern = try! Regex(from: "--(\\S+)=(\\S+)")

// TODO: Use the Arg API

public class LatexCommand: StringCommand {
	public let info = CommandInfo(
		category: .math,
		shortDescription: "Renders a LaTeX string",
		longDescription: "Parses the input as LaTeX and renders it to an image",
		helpText: "Syntax: [--color=white|black|...]? [latex code]",
		requiredPermissionLevel: .basic
	)
	public let outputValueType: RichValueType = .image
	private let latexRenderer: LatexRenderer?
	private var running = false
	
	public init() {
		do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			log.error("Could not initialize latex renderer: \(error)")
		}
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard !running else {
			output.append(errorText: "Wait for the first LaTeX command to finish")
			return
		}
		running = true
		
		guard let renderer = latexRenderer else {
			output.append(errorText: "No LaTeX renderer present")
			return
		}
		
		let flags = flagPattern.allGroups(in: input).reduce(into: [String: String]()) { $0[$1[1]] = $1[2] }
		let color = flags["color"] ?? "white"
		let processedInput = flagPattern.replace(in: input, with: "")
		
		renderLatexImage(with: renderer, from: processedInput, to: output, color: color) {
			self.running = false
		}
	}
	
	public func onSuccessfullySent(message: DiscordMessage) {
		latexRenderer?.cleanUp()
	}
}
