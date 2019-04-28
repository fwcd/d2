import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let flagPattern = try! Regex(from: "--(\\S+)=(\\S+)")

public class LatexCommand: StringCommand {
	public let description = "Renders a LaTeX string"
	public let helpText = "Syntax: [--color=white|black|...]? [latex code]"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
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
		
		renderLatexPNG(with: renderer, color: color, from: input, to: output) {
			self.running = false
		}
	}
	
	public func onSuccessfullySent(message: DiscordMessage) {
		if let renderer = latexRenderer {
			renderer.cleanUp()
		}
	}
}
