import D2NetAPIs

public class SpeedtestCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Measures the network speed",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        context.channel?.triggerTyping()
        FastQuery().perform().listen {
            do {
                let result = try $0.get()
                output.append("The network speed is \(result.megabitsPerSecond) Mbit/s")
            } catch {
                output.append(error, errorText: "Could not fetch network speed")
            }
        }
    }
}
