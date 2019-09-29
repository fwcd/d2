import SwiftDiscord
import D2Permissions
import D2Utils

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
	public let outputValueType = .image
	private let latexRenderer: LatexRenderer?
	private var running = false
	
	public init() {
		do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			print("Could not initialize latex renderer: \(error)")
		}
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard !running else {
			output.append("Wait for the first LaTeX command to finish")
			return
		}
		running = true
		
		guard let renderer = latexRenderer else {
			output.append("No LaTeX renderer present")
			return
		}
		
		let flags = flagPattern.allGroups(in: input).reduce(into: [String: String]()) { $0[$1[1]] = $1[2] }
		let color = flags["color"] ?? "white"
		let processedInput = flagPattern.replace(in: input, with: "")
		
		renderLatexPNG(with: renderer, color: color, from: processedInput, to: output) {
			self.running = false
		}
	}
	
	public func on(event: CommandEvent) -> CommandEventAction? {
		if case let .successfullySent = event, let renderer = latexRenderer {
			renderer.cleanUp()
		}
		return .none
	}
}
