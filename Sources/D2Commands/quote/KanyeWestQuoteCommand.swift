import D2MessageIO
import D2NetAPIs

public class KanyeWestQuoteCommand: StringCommand {
    public let info = CommandInfo(
        category: .quote,
        shortDescription: "Fetches a random Kanye West quote",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        KanyeRestQuery().perform().listen {
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
