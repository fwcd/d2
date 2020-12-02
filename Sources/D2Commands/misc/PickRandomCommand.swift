public class PickRandomCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Picks a random value from a space-separated list",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let value = input.split(separator: " ").randomElement().map(String.init) else {
            output.append(errorText: "Please enter space-separated values, e.g. `heads tails`.")
            return
        }

        output.append(value)
    }
}
