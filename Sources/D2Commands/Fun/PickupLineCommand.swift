import D2NetAPIs

public class PickupLineCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Outputs a random pickup line",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let line = try await PickupLineApiQuery().perform()
            await output.append(line.text)
        } catch {
            await output.append(error, errorText: "Could not fetch pickup line")
        }
    }
}
