import Utils
import D2MessageIO

fileprivate let argsPattern = #/(?<event>\S+)\s+(?<listener>\w+)/#

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
    private let eventListenerBus: EventListenerBus

    public init(eventListenerBus: EventListenerBus) {
        self.eventListenerBus = eventListenerBus
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        if let parsedArgs = try? argsPattern.firstMatch(in: input) {
            let rawEventName = String(parsedArgs.event)
            let listenerName = String(parsedArgs.listener)

            guard let event = EventListenerBus.Event(rawValue: rawEventName) else {
                output.append(errorText: "Unknown event `\(rawEventName)`, try one of these: `\(EventListenerBus.Event.allCases.map { $0.rawValue })`")
                return
            }

            eventListenerBus.addListener(name: listenerName, for: event, output: output)
            context.channel?.send(Message(content: "Added event listener!"))
        } else {
            output.append(errorText: info.helpText!)
        }
    }
}
