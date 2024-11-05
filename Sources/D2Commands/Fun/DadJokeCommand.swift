import D2NetAPIs

public class DadJokeCommand: VoidCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Fetches a random dad joke",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        do {
            let joke = try await DadJokeQuery().perform()
            await output.append(joke.joke)
        } catch {
            await output.append(error, errorText: "Could not fetch dad joke")
        }
    }
}
