import Utils

nonisolated(unsafe) private let wPattern = #/[rl]/#.ignoresCase()
nonisolated(unsafe) private let punctuationPattern = #/[!\.]/#

public class UwUifyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Transforms the text into an uwuish form",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let transformed = input
            .replacing(wPattern, with: "w")
            .replacing(punctuationPattern) { "\($0.0) \(["UwU", "OwO", ">w<", "oωo", ".ω."].randomElement()!)." }
        await output.append(transformed)
    }
}
