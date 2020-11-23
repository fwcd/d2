import Logging
import Utils

fileprivate let log = Logger(label: "D2Commands.LoveCommand")

public class LoveCommand: Command {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Determines the chance of love between you and someone else",
        helpText: "Syntax: [user]",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"]
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let author = context.author, let other = input.asMentions?.first else {
            output.append(errorText: info.helpText!)
            return
        }
        guard let authorId = Int(author.id.value), let otherId = Int(other.id.value) else {
            output.append(errorText: "Numerical IDs needed!")
            return
        }
        guard author.id != other.id else {
            output.append(errorText: "Please mention someone other than yourself!")
            return
        }

        let basePrecision = 1000
        let baseHash = (authorId % basePrecision) ^ (otherId % basePrecision)
        let components: [(weight: Double, value: Double)] = [
            (weight: 8, value: Double(abs(baseHash % basePrecision)) / Double(basePrecision)),
            (weight: 1, value: 1 - min(1, Double(author.username.levenshteinDistance(to: other.username)) / 40)),
            (weight: 2, value: author.bot == other.bot ? 0.8 : 0.1)
        ]
        let chance = components.map { $0.weight * $0.value }.reduce(0, +) / components.map(\.weight).reduce(0, +)

        log.debug("Components: \(components)")
        output.append(":heart: There is a \(Int(chance * 100))% chance of love between <@\(author.id)> and <@\(other.id)>")
    }
}
