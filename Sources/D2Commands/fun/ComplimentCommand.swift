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

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        ComplimentrQuery().perform().listen {
            do {
                let compliment = try $0.get()
                output.append(compliment.compliment)
            } catch {
                output.append(error, errorText: "Could not fetch compliment")
            }
        }
    }
}
