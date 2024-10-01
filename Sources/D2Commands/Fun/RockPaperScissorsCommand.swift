import Utils

public class RockPaperScissorsCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Lets you play rock-paper-scissors with D2",
        helpText: "Syntax: [\(RockPaperScissors.allCases.map(\.emoji).joined(separator: "|"))]",
        requiredPermissionLevel: .basic
    )

    private enum RockPaperScissors: String, CaseIterable {
        case rock
        case paper
        case scissors

        private static let emojis: BiDictionary<RockPaperScissors, String> = [
            .rock: ":fist:",
            .paper: ":raised_hand:",
            .scissors: ":v:"
        ]
        var emoji: String { Self.emojis[self]! }

        init?(from s: String) {
            if let rps = Self.emojis[value: s] {
                self = rps
            } else {
                self.init(rawValue: s)
            }
        }

        func beats(_ other: RockPaperScissors) -> Bool? {
            guard self != other else { return nil }
            return switch self {
                case .rock: other == .scissors
                case .paper: other == .rock
                case .scissors: other == .paper
            }
        }
    }

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let yourChoice = RockPaperScissors(from: input) else {
            await output.append(errorText: info.helpText!)
            return
        }

        let myChoice = RockPaperScissors.allCases.randomElement()!
        switch yourChoice.beats(myChoice) {
            case true?: await output.append("Yay, your \(yourChoice.emoji) beat my choice of \(myChoice.emoji)!")
            case false?: await output.append("Sorry, my \(myChoice.emoji) beat your \(yourChoice.emoji). Maybe next time!")
            case nil: await output.append("Draw!")
        }
    }
}
