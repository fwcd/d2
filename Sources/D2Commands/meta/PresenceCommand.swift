import D2MessageIO
import D2Permissions
import Utils

fileprivate let activityTypes: [String: Presence.Activity.ActivityType] = [
    "playing": .game,
    "streaming": .stream,
    "listening": .listening
]
fileprivate let availableStatusTypes = "idle|offline|online|dnd"
fileprivate let argsPattern = try! LegacyRegex(from: "(\(activityTypes.keys.joined(separator: "|")))\\s+(?:(\(availableStatusTypes))\\s+)?(.+)")

public class PresenceCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Updates D2's presence",
        longDescription: "Updates the game activity and status",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        if let parsedArgs = argsPattern.firstGroups(in: input) {
            let activityType = activityTypes[parsedArgs[1]]!
            let status = parsedArgs[2].nilIfEmpty.flatMap { Presence.Status(rawValue: $0) } ?? .online
            let customText = parsedArgs[3]

            guard let sink = context.sink else {
                output.append(errorText: "No client found")
                return
            }

            sink.setPresence(PresenceUpdate(activities: [Presence.Activity(name: customText, type: activityType)], status: status))
        } else {
            output.append(errorText: "Syntax: [\(activityTypes.keys.joined(separator: "|"))] [\(availableStatusTypes)]? [custom text]")
        }
    }
}
