import D2Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.LatexUtils")

func handleLatex(error: Error, output: CommandOutput) {
	if case let LatexError.pdfError(pdfLog) = error {
		output.append(error, errorText: "A LaTeX PDF error occurred:\n```\n\(extractLatexError(from: pdfLog))\n```")
	} else {
		output.append(error, errorText: "An asynchronous LaTeX error occurred")
	}
}

@discardableResult
func renderLatexImage(with renderer: LatexRenderer, from input: String, to output: CommandOutput, color: String = "white", scale: Double = 6) -> Promise<Void, Error> {
    renderer.renderImage(from: input, color: color, scale: scale).peekListen {
        // Render output
        do {
            try output.append($0.get())
        } catch let LatexError.pdfError(pdfLog) {
            output.append(errorText: "A LaTeX PDF error occurred:\n```\n\(extractLatexError(from: pdfLog))\n```")
        } catch {
            output.append(error, errorText: "An asynchronous LaTeX error occurred")
        }
    }.swallow()
}

private func extractLatexError(from log: String) -> String {
	return log.components(separatedBy: "\n")
		.filter { $0.starts(with: "!") }
		.joined(separator: "\n")
		.nilIfEmpty
		?? "Unknown error"
}
