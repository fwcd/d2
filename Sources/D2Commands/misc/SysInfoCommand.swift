import D2MessageIO
import Utils
import PerfectSysInfo

public class SysInfoCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches diagnostic information like memory and CPU usage",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        let cpuUsage = SysInfo.CPU
        let memoryUsage = SysInfo.Memory

        // TODO: Use the equivalent macOS values, see https://github.com/PerfectlySoft/Perfect-SysInfo#memory-usage
        let totalMemory = memoryUsage["MemTotal"] // in MB
        let usedMemory = memoryUsage["MemAvailable"].flatMap { a in totalMemory.map { $0 - a } } // in MB

        output.append(Embed(
            title: ":clock1: System Information",
            fields: [
                Embed.Field(name: "CPU Usage", value: cpuUsage
                    .sorted(by: ascendingComparator { $0.key })
                    .map { "**\($0.key)**: \($0.value.sorted(by: ascendingComparator { $0.key }).map { "\($0.key): \($0.value)" }.joined(separator: ", "))" }
                    .joined(separator: "\n")
                    .nilIfEmpty ?? "_none_"),
                Embed.Field(name: "Memory Usage", value: "\(usedMemory.map { "\($0)" } ?? "?") MB of \(totalMemory.map { "\($0)" } ?? "?") MB")
            ]
        ))
    }
}
