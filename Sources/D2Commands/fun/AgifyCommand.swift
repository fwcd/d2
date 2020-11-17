import D2MessageIO
import D2NetAPIs
import Utils

public class AgifyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Predicts the age of a person given their name",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter a name!")
            return
        }

        AgifyQuery(name: input).perform().listen {
            do {
                let estimate = try $0.get()
                output.append(Embed(
                    title: "Age Estimate: \(estimate.age) \("year".pluralized(with: estimate.age))"
                ))
            } catch {
                output.append(error, errorText: "Could not fetch estimate")
            }
        }
    }
}
