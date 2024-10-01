import D2MessageIO
import Logging
import Utils

fileprivate let log = Logger(label: "D2Commands.LoveCommand")

public class LoveCommand: Command {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Determines the chance of love between two persons",
        helpText: "Syntax: [user]? [user]",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"]
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let (first, second) = extractMentions(input: input, context: context) else {
            await output.append(errorText: info.helpText!)
            return
        }
        guard let firstId = Int(first.id.value), let secondId = Int(second.id.value) else {
            await output.append(errorText: "Numerical IDs needed!")
            return
        }
        guard first.id != second.id else {
            await output.append(errorText: "Please specify two different persons!")
            return
        }

        let basePrecision = 1000
        let baseHash = (firstId % basePrecision) ^ (secondId % basePrecision)
        let components: [(weight: Double, value: Double)] = [
            (weight: 8, value: Double(abs(baseHash % basePrecision)) / Double(basePrecision)),
            (weight: 1, value: 1 - min(1, Double(first.username.levenshteinDistance(to: second.username)) / 40)),
            (weight: 2, value: first.bot == second.bot ? 0.8 : 0.1)
        ]
        let chance = components.map { $0.weight * $0.value }.reduce(0, +) / components.map(\.weight).reduce(0, +)

        log.debug("Components: \(components)")
        await output.append(":heart: There is a \(Int(chance * 100))% chance of love between <@\(first.id)> and <@\(second.id)>")
    }

    private func extractMentions(input: RichValue, context: CommandContext) -> (User, User)? {
        guard let mentions = input.asMentions else { return nil }
        return switch mentions.count {
            case 1: context.author.map { ($0, mentions[0]) }
            case 2: (mentions[0], mentions[1])
            default: nil
        }
    }
}
