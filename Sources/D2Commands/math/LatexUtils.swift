import Logging

fileprivate let log = Logger(label: "LatexUtils")

func handleLatex(error: Error, output: CommandOutput) {
	if case let LatexError.pdfError(pdfLog) = error {
		output.append("A LaTeX PDF error occurred:\n```\n\(extractLatexError(from: pdfLog))\n```")
		log.warning("LaTeX PDF error:\n\(pdfLog)")
	} else {
		output.append("An asynchronous LaTeX error occurred")
		log.warning("Asynchronous LaTeX error: \(error)")
	}
}

func renderLatexPNG(with renderer: LatexRenderer, color: String = "white", from input: String, to output: CommandOutput, then: @escaping () -> Void) {
	do {
		try renderer.renderImage(from: input, color: color, onError: {
			// Catch asynchronous errors
			handleLatex(error: $0, output: output)
			then()
		}) {
			// Render output
			do {
				try output.append($0)
			} catch {
				output.append("Error while appending image to output")
				log.error("Error while appending image to output: \(error)")
			}
			then()
		}
	} catch {
		handleLatex(error: error, output: output)
		then()
	}
}

private func extractLatexError(from log: String) -> String {
	return log.components(separatedBy: "\n")
		.filter { $0.starts(with: "!") }
		.joined(separator: "\n")
		.nilIfEmpty
		?? "Unknown error"
}
