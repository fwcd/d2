import D2NetAPIs

public class FactCommand: VoidCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Outputs a random fact",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        do {
            let fact = try await RandomFactQuery(language: "en").perform()
            await output.append(fact.text)
        } catch {
            await output.append(error, errorText: "Could not fetch fact")
        }
    }
}
