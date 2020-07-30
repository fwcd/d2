import D2NetAPIs

public class PickupLineCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Outputs a random pickup line",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let queries: [PickupLineQuery] = [PebblePickupQuery(), PickupLineGenQuery()]
        queries.randomElement()!.perform().listen {
            do {
                let line = try $0.get()
                output.append(line.tweet)
            } catch {
                output.append(error, errorText: "Could not fetch pickup line")
            }
        }
    }
}
