import D2MessageIO
import D2Permissions
import RegexBuilder
import Utils

fileprivate let activityTypes: [String: Presence.Activity.ActivityType] = [
    "playing": .game,
    "streaming": .stream,
    "listening": .listening
]
fileprivate let availableStatusTypes = ["idle", "offline", "online", "dnd"]
fileprivate let argsPattern = Regex {
    Capture {
        ChoiceOf(nonEmptyComponents: activityTypes.keys)
    } transform: {
        activityTypes[String($0)]
    }
    #/\s+/#
    Optionally {
        Capture {
            ChoiceOf(nonEmptyComponents: availableStatusTypes)
        } transform: {
            Presence.Status(rawValue: String($0))
        }
        #/\s+/#
    }
    Capture {
        #/.+/#
    }
}

public class PresenceCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Updates D2's presence",
        longDescription: "Updates the game activity and status",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if let parsedArgs = try? argsPattern.firstMatch(in: input) {
            let activityType = parsedArgs.1!
            let status = parsedArgs.2 ?? .online
            let customText = String(parsedArgs.3)

            guard let sink = context.sink else {
                await output.append(errorText: "No client found")
                return
            }

            do {
                try await sink.setPresence(PresenceUpdate(activities: [Presence.Activity(name: customText, type: activityType)], status: status))
            } catch {
                await output.append(error, errorText: "Could not set presence")
            }
        } else {
            await output.append(errorText: "Syntax: [\(activityTypes.keys.joined(separator: "|"))] [\(availableStatusTypes.joined(separator: "|"))]? [custom text]")
        }
    }
}
