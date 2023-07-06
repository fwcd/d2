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
                let speed = try $0.get()
                output.append(String(format: "The network speed is %.2f Mbit/s", speed.megabitsPerSecond))
            } catch {
                output.append(error, errorText: "Could not fetch network speed")
            }
        }
    }
}
