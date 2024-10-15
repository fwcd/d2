import Utils
import MusicTheory

fileprivate let scales: [String: (Note) -> Scale] = [
    "major": MajorScale.init,
    "minor": MinorScale.init,
    "blues": MinorBluesScale.init,
    "pentatonic": MajorPentatonicScale.init,
]

public class PianoScaleCommand: RegexCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Renders a musical scale on a piano keyboard",
        helpText: """
            Syntax: `[scale]? [key]`

            For example: `c`, `major e`, `minor d#`
            """,
        requiredPermissionLevel: .basic
    )
    public let inputPattern = #/(?:(?<scale>\w+)\s+)?(?<key>\w+[b#]?)/#
    public let outputValueType: RichValueType = .image
    private let defaultScale: String

    public init(defaultScale: String = "major") {
        self.defaultScale = defaultScale
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        do {
            let rawScale = input.scale.map { String($0) } ?? defaultScale
            let rawKey = String(input.key)

            guard let scale = scales[rawScale] else {
                await output.append(errorText: "Unknown scale `\(rawScale)`. Try one of these: \(scales.keys.map { "`\($0)`" }.joined(separator: ", "))")
                return
            }
            guard let key = try? Note(parsing: rawKey) else {
                await output.append(errorText: "Could not parse key `\(rawKey)` as a note. Try something like e.g. `C3`.")
                return
            }

            let c = try Note(parsing: "C3")
            let image = try PianoRenderer(lowerBound: c, upperBound: c + .octave + .octave).render(scale: scale(key))
            try await output.append(image)
        } catch {
            await output.append(error, errorText: "Could not render scale.")
        }
    }
}
