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
            switch self {
                case .rock: return other == .scissors
                case .paper: return other == .rock
                case .scissors: return other == .paper
            }
        }
    }

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let yourChoice = RockPaperScissors(from: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        let myChoice = RockPaperScissors.allCases.randomElement()!
        switch yourChoice.beats(myChoice) {
            case true?: output.append("Yay, your \(yourChoice.emoji) beat my choice of \(myChoice.emoji)!")
            case false?: output.append("Sorry, my \(myChoice.emoji) beat your \(yourChoice.emoji). Maybe next time!")
            case nil: output.append("Draw!")
        }
    }
}
