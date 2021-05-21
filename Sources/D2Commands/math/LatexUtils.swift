import Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.LatexUtils")

extension LatexRenderer {
    @discardableResult
    func renderImage(from input: String, to output: CommandOutput, color: String = "white", scale: Double = 2) -> Promise<Void, Error> {
        renderImage(from: input, color: color, scale: scale).peekListen {
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
}

private func extractLatexError(from log: String) -> String {
    return log.components(separatedBy: "\n")
        .filter { $0.starts(with: "!") }
        .joined(separator: "\n")
        .nilIfEmpty
        ?? "Unknown error"
}
