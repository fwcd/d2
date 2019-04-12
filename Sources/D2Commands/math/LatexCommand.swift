import SwiftDiscord
import D2Permissions

public class LatexCommand: StringCommand {
	public let description = "Renders a LaTeX string"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let renderer = LatexRenderer()
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			try renderer.renderPNG(from: input) {
				try output.append($0)
			}
		} catch {
			output.append("Error while rendering LaTeX")
			print("Error while rendering LaTeX to PNG: \(error)")
		}
	}
}
