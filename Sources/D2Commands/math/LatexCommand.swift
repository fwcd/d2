import SwiftDiscord
import D2Permissions

public class LatexCommand: StringCommand {
	public let description = "Renders a LaTeX string"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let latexRenderer: LatexRenderer?
	
	public init() {
		do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			print("Could not initialize latex renderer.")
		}
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let renderer = latexRenderer else {
			output.append("No LaTeX renderer present")
			return
		}
		
		do {
			try renderer.renderPNG(from: input) {
				do {
					try output.append($0)
				} catch {
					output.append("Error while appending image to output")
					print("Error while appending image to output: \(error)")
				}
			}
		} catch LatexError.pdfError(let log) {
			output.append("PDF Error while rendering LaTeX: ```\n\(log)\n```")
			print("PDF Error while rendering LaTeX to PNG: \(log)")
		} catch {
			output.append("Error while rendering LaTeX")
			print("Error while rendering LaTeX to PNG: \(error)")
		}
	}
}
