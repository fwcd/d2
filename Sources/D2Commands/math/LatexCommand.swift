import Logging
import D2MessageIO
import D2Permissions
import Utils

fileprivate let log = Logger(label: "D2Commands.LatexCommand")
fileprivate let flagPattern = try! LegacyRegex(from: "--(\\S+)=(\\S+)")

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard !running else {
            output.append(errorText: "Wait for the first LaTeX command to finish")
            return
        }
        guard !input.isEmpty else {
            output.append(errorText: "Please enter a formula to render!")
            return
        }
        running = true

        let flags = flagPattern.allGroups(in: input).reduce(into: [String: String]()) { $0[$1[1]] = $1[2] }
        let color = flags["color"] ?? "white"
        let processedInput = flagPattern.replace(in: input, with: "")

        latexRenderer.renderImage(from: processedInput, to: output, color: color).listenOrLogError {
            self.running = false
        }
    }
}
