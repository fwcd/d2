import D2MessageIO
import D2Permissions
import D2Utils

fileprivate let activityTypes: [String: Presence.Activity.ActivityType] = [
    "playing": .game,
    "streaming": .stream,
    "listening": .listening
]
fileprivate let availableStatusTypes = "idle|offline|online|dnd"
fileprivate let argsPattern = try! Regex(from: "(\(activityTypes.keys.joined(separator: "|")))\\s+(?:(\(availableStatusTypes))\\s+)?(.+)")

public class PresenceCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Updates D2's presence",
        longDescription: "Updates the game activity and status",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        if let parsedArgs = argsPattern.firstGroups(in: input) {
            let activityType = activityTypes[parsedArgs[1]]!
            let status = parsedArgs[2].nilIfEmpty.flatMap { Presence.Status(rawValue: $0) } ?? .online
            let customText = parsedArgs[3]

            guard let client = context.client else {
                output.append(errorText: "No client found")
                return
            }

            client.setPresence(PresenceUpdate(game: Presence.Activity(name: customText, type: activityType), status: status))
        } else {
            output.append(errorText: "Syntax: [\(activityTypes.keys.joined(separator: "|"))] [\(availableStatusTypes)]? [custom text]")
        }
    }
}
