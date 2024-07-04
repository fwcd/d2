import D2MessageIO
import D2NetAPIs

public class TaylorSwiftQuoteCommand: StringCommand {
    public let info = CommandInfo(
        category: .quote,
        shortDescription: "Fetches a random Taylor Swift quote",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let quote = try await TaylorRestQuery().perform().quote
            await output.append(Embed(
                description: "**\(quote)**"
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch quote")
        }
    }
}
