import D2Utils

fileprivate let argsPattern = try! Regex(from: "(\\w+)\\s+(\\w+)")

public class RemoveEventListenerCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Deregisters an event handler",
        helpText: """
            Syntax: [listener name]
            """,
        requiredPermissionLevel: .admin
    )
    private let eventBus: EventBus

    public init(eventBus: EventBus) {
        self.eventBus = eventBus
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if let parsedArgs = argsPattern.firstGroups(in: input) {
            let listenerName = parsedArgs[1]

            eventBus.removeListener(name: listenerName)
            output.append("Removed listener (if present)!")
        } else {
            output.append(errorText: info.helpText!)
        }
    }
}