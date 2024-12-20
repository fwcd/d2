import Logging
import D2MessageIO
import D2Permissions
import Utils

private let log = Logger(label: "D2Commands.LatexCommand")
nonisolated(unsafe) private let flagPattern = #/--(\S+)=(\S+)/#

// TODO: Use the Arg API

public class LatexCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Renders a LaTeX string",
        longDescription: "Parses the input as LaTeX and renders it to an image",
        helpText: "Syntax: [--color=white|black|...]? [latex code]",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .image
    private let latexRenderer = LatexRenderer()
    private var running = false

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !running else {
            await output.append(errorText: "Wait for the first LaTeX command to finish")
            return
        }
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a formula to render!")
            return
        }
        running = true

        let flags = input.matches(of: flagPattern).reduce(into: [String: String]()) { $0[String($1.1)] = String($1.2) }
        let color = flags["color"] ?? "white"
        let processedInput = input.replacing(flagPattern, with: "")

        await latexRenderer.renderImage(from: processedInput, to: output, color: color)
        running = false
    }
}
