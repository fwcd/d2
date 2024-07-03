import D2NetAPIs
import D2MessageIO
import Utils

public class DiscordStatusCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the online status of Discord's services",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let status = try await DiscordStatusQuery().perform()
            await output.append(Embed(
                title: ":traffic_light: Discord Status",
                description: (status.components ?? [])
                    .map { "**\($0.name)**: \(self.indicatorOf(status: $0.status))" }
                    .joined(separator: "\n")
                    .nilIfEmpty
                    ?? "_none_"
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch Discord status")
        }
    }

    private func indicatorOf(status: String) -> String {
        switch status {
            case "operational": return ":green_circle: Operational"
            case "under_maintenance": return ":yellow_circle: Under maintainance"
            case "degraded_performance": return ":yellow_circle: Degraded performance"
            case "partial_outage": return ":yellow_circle: Partial outage"
            case "major_outage": return ":red_circle: Major outage"
            default: return ":white_circle: Unknown"
        }
    }
}
