import Logging

fileprivate let log = Logger(label: "LatexUtils")

func handleLatex(error: Error, output: CommandOutput) {
	if case let LatexError.pdfError(pdfLog) = error {
		output.append(error, errorText: "A LaTeX PDF error occurred:\n```\n\(extractLatexError(from: pdfLog))\n```")
	} else {
		output.append(error, errorText: "An asynchronous LaTeX error occurred")
	}
}

func renderLatexPNG(with renderer: LatexRenderer, color: String = "white", from input: String, to output: CommandOutput, then: (() -> Void)? = nil) {
	do {
		try renderer.renderImage(from: input, color: color, onError: {
			// Catch asynchronous errors
			handleLatex(error: $0, output: output)
			then?()
		}) {
			// Render output
			do {
				try output.append($0)
			} catch {
				output.append(error, errorText: "Error while appending image to output")
			}
			then?()
		}
	} catch {
		handleLatex(error: error, output: output)
		then?()
	}
}

private func extractLatexError(from log: String) -> String {
	return log.components(separatedBy: "\n")
		.filter { $0.starts(with: "!") }
		.joined(separator: "\n")
		.nilIfEmpty
		?? "Unknown error"
}
