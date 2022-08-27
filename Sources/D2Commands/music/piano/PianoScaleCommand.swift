import Utils
import MusicTheory

fileprivate let argsPattern = try! Regex(from: "(?:(\\w+)\\s+)?(\\w+[b#]?)")
fileprivate let scales: [String: (Note) -> Scale] = [
    "major": MajorScale.init,
    "minor": MinorScale.init,
    "blues": MinorBluesScale.init,
    "pentatonic": MajorPentatonicScale.init,
]

public class PianoScaleCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Renders a musical scale on a piano keyboard",
        helpText: """
            Syntax: `[scale]? [key]`

            For example: `c`, `major e`, `minor d#`
            """,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .image
    private let defaultScale: String

    public init(defaultScale: String = "major") {
        self.defaultScale = defaultScale
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        do {
            guard let parsedArgs = argsPattern.firstGroups(in: input) else {
                output.append(errorText: info.helpText!)
                return
            }

            let rawScale = parsedArgs[1].nilIfEmpty ?? defaultScale
            let rawKey = parsedArgs[2].nilIfEmpty ?? "C3"

            guard let scale = scales[rawScale] else {
                output.append(errorText: "Unknown scale `\(rawScale)`. Try one of these: \(scales.keys.map { "`\($0)`" }.joined(separator: ", "))")
                return
            }
            guard let key = try? Note(parsing: rawKey) else {
                output.append(errorText: "Could not parse key `\(rawKey)` as a note. Try something like e.g. `C3`.")
                return
            }

            let c = try Note(parsing: "C3")
            let image = try PianoRenderer(lowerBound: c, upperBound: c + .octave + .octave).render(scale: scale(key))
            try output.append(image)
        } catch {
            output.append(error, errorText: "Could not render scale.")
        }
    }
}
