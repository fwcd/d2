import D2MessageIO
import D2NetAPIs

public class TaylorSwiftQuoteCommand: StringCommand {
    public let info = CommandInfo(
        category: .quote,
        shortDescription: "Fetches a random Taylor Swift quote",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        TaylorRestQuery().perform().listen {
            do {
                output.append(Embed(
                    description: "**\(try $0.get().quote)**"
                ))
            } catch {
                output.append(error, errorText: "Could not fetch quote")
            }
        }
    }
}
