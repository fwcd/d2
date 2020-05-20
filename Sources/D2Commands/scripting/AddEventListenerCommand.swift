import D2Utils

fileprivate let argsPattern = try! Regex(from: "(\\w+)\\s+(\\w+)")

public class AddEventListenerCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Registers an event handler",
        helpText: """
            Syntax: [event name] [listener name]
            
            Pipe this command into another command which is to be invoked!
            """,
        requiredPermissionLevel: .admin
    )
    private let eventBus: EventBus

    public init(eventBus: EventBus) {
        self.eventBus = eventBus
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if let parsedArgs = argsPattern.firstGroups(in: input) {
            let rawEventName = parsedArgs[1]
            let listenerName = parsedArgs[2]

            guard let event = EventBus.Event(rawValue: rawEventName) else {
                output.append(errorText: "Unknown event `\(rawEventName)`, try one of these: `\(EventBus.Event.allCases.map { $0.rawValue })`")
                return
            }

            eventBus.addListener(name: listenerName, for: event, output: output)
            output.append("Added event listener!")
        } else {
            output.append(errorText: info.helpText!)
        }
    }
}