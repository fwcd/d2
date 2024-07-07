import D2NetAPIs

public class SpeedtestCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Measures the network speed",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let speed = try await FastQuery().perform()
            await output.append(String(format: "The network speed is %.2f Mbit/s", speed.megabitsPerSecond))
        } catch {
            await output.append(error, errorText: "Could not fetch network speed")
        }
    }
}
