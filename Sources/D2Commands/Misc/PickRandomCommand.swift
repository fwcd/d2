public class PickRandomCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Picks a random value from a space-separated list",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let value = input.split(separator: " ").randomElement().map(String.init) else {
            await output.append(errorText: "Please enter space-separated values, e.g. `heads tails`.")
            return
        }

        await output.append(value)
    }
}
