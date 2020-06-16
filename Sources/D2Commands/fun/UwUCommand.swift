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
	private let latexRenderer: LatexRenderer?
    private var running: Bool = false

    public init() {
		do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			log.error("Could not initialize latex renderer: \(error)")
		}
	}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard !running else {
            output.append(errorText: "Please wait for the first render to finish!")
            return
        }
        guard let renderer = latexRenderer else {
            output.append(errorText: "LaTeX renderer could not be initialized!")
            return
        }
        running = true
        renderLatexImage(with: renderer, from: "\\mathcal{O}\\omega\\mathcal{O}", to: output) {
			self.running = false
		}
    }
}
