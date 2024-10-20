import D2MessageIO

private let diceFaces = [
    1: [[false, false, false], [false, true, false], [false, false, false]],
    2: [[false, false, true], [false, false, false], [true, false, false]],
    3: [[false, false, true], [false, true, false], [true, false, false]],
    4: [[true, false, true], [false, false, false], [true, false, true]],
    5: [[true, false, true], [false, true, false], [true, false, true]],
    6: [[true, true, true], [false, false, false], [true, true, true]]
]

public class DiceRollCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Rolls a dice",
        longDescription: "Emits a random number between 1 and 6 (inclusive)",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let range: Range<Int>
    private let fancy: Bool

    public convenience init(_ closedRange: ClosedRange<Int>, fancy: Bool = true) {
        self.init(Range(closedRange), fancy: fancy)
    }

    public init(_ range: Range<Int>, fancy: Bool = true) {
        self.range = range
        self.fancy = fancy
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let result = Int.random(in: range)

        if fancy {
            await output.append(Embed(
                title: "Result: \(result)",
                description: diceFaces[result].map { $0.map { $0.map { $0 ? ":white_square_button:" : ":white_large_square:" }.joined() }.joined(separator: "\n") }
            ))
        } else {
            await output.append("\(result)")
        }
    }
}
