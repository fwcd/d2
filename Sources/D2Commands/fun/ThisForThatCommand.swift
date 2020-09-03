import D2NetAPIs

public class ThisForThatCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Fetches an idea about what to create",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        ThisForThatQuery().perform().listen {
            do {
                let tft = try $0.get()
                output.append("**\(tft.this)** for **\(tft.that)**")
            } catch {
                output.append(error, errorText: "Could not fetch this for that")
            }
        }
    }
}
