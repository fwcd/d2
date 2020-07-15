public class PianoScaleCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Renders a musical scale on a piano keyboard",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let c = try Note(of: "C3")
            let image = try PianoRenderer(range: Range(c...(c + .octave + .octave))).render(scale: DiatonicMajorScale(key: Note(of: input)))
            try output.append(image)
        } catch {
            output.append(error, errorText: "Could not render scale.")
        }
    }
}
