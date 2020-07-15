public class PianoScaleCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Renders a musical scale on a piano keyboard",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        // TODO
        do {
            let c = try Note(of: "C3")
            let image = try PianoRenderer(range: Range(c...(c + .octave))).render(scale: DiatonicMajorScale(key: Note(of: "C2")))
            try output.append(image)
        } catch {
            output.append(error, errorText: "Could not render scale.")
        }
    }
}
