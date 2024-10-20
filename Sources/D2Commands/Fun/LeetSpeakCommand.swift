private let substitutions: [Character: Character] = [
    "A": "4",
    "E": "3",
    "O": "0",
    "L": "1",
    "T": "7",
    "S": "$",
    "B": "6",
    "I": "!"
]

public class LeetSpeakCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Converts text into leetspeak",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        await output.append(String(input.map { substitutions[Character($0.uppercased())] ?? $0 }))
    }
}
