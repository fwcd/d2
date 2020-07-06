public class DiceRollCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Rolls a dice",
        longDescription: "Emits a random number between 1 and 6 (inclusive)",
        requiredPermissionLevel: .basic
    )
    private let range: Range<Int>

    public convenience init(_ closedRange: ClosedRange<Int>) {
        self.init(Range(closedRange))
    }

    public init(_ range: Range<Int>) {
        self.range = range
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let result = Int.random(in: range)
        output.append("\(result)")
    }
}
