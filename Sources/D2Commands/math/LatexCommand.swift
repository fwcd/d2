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
			try renderer.renderPNG(from: input, onError: { self.handle(error: $0, output: output) }) {
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
	
	private func handle(error: Error, output: CommandOutput) {
		if case let LatexError.pdfError(log) = error {
			output.append("A LaTeX PDF error occurred:\n```\n\(extractError(from: log))\n```")
			print("LaTeX PDF error:")
			print(log)
		} else {
			output.append("An asynchronous LaTeX error occurred")
			print("Asynchronous LaTeX error: \(error)")
		}
	}
	
	private func extractError(from log: String) -> String {
		return log.components(separatedBy: "\n")
			.filter { $0.starts(with: "!") }
			.joined(separator: "\n")
			.nilIfEmpty
			?? "Unknown error"
	}
	
	public func onSuccessfullySent(message: DiscordMessage) {
		if let renderer = latexRenderer {
			renderer.cleanUp()
		}
	}
}
