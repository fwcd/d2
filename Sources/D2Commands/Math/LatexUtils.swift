import Utils
import Logging

private let log = Logger(label: "D2Commands.LatexUtils")

extension LatexRenderer {
    func renderImage(
        from input: String,
        to output: any CommandOutput,
        color: String = "white",
        scale: Double = 2,
        isolation: isolated (any Actor)? = #isolation
    ) async {
        do {
            let image = try await renderImage(from: input, color: color, scale: scale)
            try await output.append(image)
        } catch let LatexError.pdfError(pdfLog) {
            await output.append(errorText: "A LaTeX PDF error occurred:\n```\n\(extractLatexError(from: pdfLog))\n```")
        } catch {
            await output.append(error, errorText: "An asynchronous LaTeX error occurred")
        }
    }
}

private func extractLatexError(from log: String) -> String {
    return log.components(separatedBy: "\n")
        .filter { $0.starts(with: "!") }
        .joined(separator: "\n")
        .nilIfEmpty
        ?? "Unknown error"
}
