import D2MessageIO
import D2NetAPIs

public class ComplimentCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Sends a compliment",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let compliment = try await ComplimentrQuery().perform()
            await output.append(compliment.compliment)
        } catch {
            await output.append(error, errorText: "Could not fetch compliment")
        }
    }
}
