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
        guard author.id != other.id else {
            output.append(errorText: "Please mention someone other than yourself!")
            return
        }

        var hasher = Hasher()
        hasher.combine(Set([author.id, other.id]))

        let basePrecision = 1000
        let components = [
            Double(abs(hasher.finalize() % basePrecision)) / Double(basePrecision),
            1 - min(1, Double(author.username.levenshteinDistance(to: other.username)) / 10),
            author.bot == other.bot ? 0.8 : 0.1
        ]
        let chance = components.reduce(0, +) / Double(components.count)

        log.info("Components: \(components)")
        output.append(":heart: There is a \(Int(chance * 100))% chance of love between <@\(author.id)> and <@\(other.id)>")
    }
}
