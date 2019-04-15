import SwiftDiscord
import D2Permissions

public class LatexCommand: StringCommand {
	public let description = "Renders a LaTeX string"
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
		
		renderLatexPNG(with: renderer, from: input, to: output) {
			self.running = false
		}
	}
	
	public func onSuccessfullySent(message: DiscordMessage) {
		if let renderer = latexRenderer {
			renderer.cleanUp()
		}
	}
}
