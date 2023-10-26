import D2MessageIO
import Foundation
import Utils

public class RestartsCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Fetches the last restarts",
        requiredPermissionLevel: .vip
    )

    @AutoSerializing(filePath: "local/restarts.json") private var restarts: [Restart] = []

    public init(maxRestarts: Int = 25, hostInfo: HostInfo) {
        restarts = restarts.suffix(maxRestarts)
        restarts.append(Restart(instanceName: hostInfo.instanceName))
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        output.append(.table(restarts.map {
            [dateFormatter.string(from: $0.timestamp), $0.instanceName ?? "?"]
        }))
    }
}
