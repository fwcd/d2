import D2NetAPIs

public class FactCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Outputs a random fact",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        RandomFactQuery(language: "en").perform().listen {
            do {
                let fact = try $0.get()
                output.append(fact.text)
            } catch {
                output.append(error, errorText: "Could not fetch fact")
            }
        }
    }
}
