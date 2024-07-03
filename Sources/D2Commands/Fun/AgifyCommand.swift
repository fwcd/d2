import D2MessageIO
import D2NetAPIs
import Utils

public class AgifyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Predicts the age of a person given their name",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a name!")
            return
        }

        do {
            let estimate = try await AgifyQuery(name: input).perform()
            await output.append(Embed(
                title: "Age Estimate: \(estimate.age) \("year".pluralized(with: estimate.age))"
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch estimate")
        }
    }
}
