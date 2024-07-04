import D2NetAPIs

public class ThisForThatCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Fetches an idea about what to create",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let tft = try await ThisForThatQuery().perform()
            await output.append("**\(tft.this)** for **\(tft.that)**")
        } catch {
            await output.append(error, errorText: "Could not fetch this for that")
        }
    }
}
