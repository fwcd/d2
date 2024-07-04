import D2MessageIO
import Foundation
import Utils

public class UptimeCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Fetches the uptime",
        requiredPermissionLevel: .basic
    )

    private let startDate: Date

    public init(startDate: Date = Date()) {
        self.startDate = startDate
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) async {
        let time = -startDate.timeIntervalSinceNow
        await output.append("D2 has been running for \(time.displayString)")
    }
}
