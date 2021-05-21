import Logging

fileprivate let log = Logger(label: "D2Commands.UwUCommand")

public class UwUCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Sends a nice smiley",
        requiredPermissionLevel: .basic,
        hidden: true
    )
    public let outputValueType: RichValueType = .image
    private let latexRenderer = LatexRenderer()
    private var running: Bool = false

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !running else {
            output.append(errorText: "Please wait for the first render to finish!")
            return
        }
        running = true
        renderLatexImage(with: latexRenderer, from: "\\mathcal{O}\\omega\\mathcal{O}", to: output).listenOrLogError {
            self.running = false
        }
    }
}
