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
        let chance = abs(hasher.finalize() % 100)

        output.append(":heart: There is a \(chance)% chance of love between <@\(author.id)> and <@\(other.id)>")
    }
}
