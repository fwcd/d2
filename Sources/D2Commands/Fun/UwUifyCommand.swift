import Utils

fileprivate let wPattern = #/[rl]/#.ignoresCase()
fileprivate let punctuationPattern = #/[!\.]/#

public class UwUifyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Transforms the text into an uwuish form",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        let transformed = input
            .replacing(wPattern, with: "w")
            .replacing(punctuationPattern) { "\($0.0) \(["UwU", "OwO", ">w<", "oωo", ".ω."].randomElement()!)." }
        output.append(transformed)
    }
}
