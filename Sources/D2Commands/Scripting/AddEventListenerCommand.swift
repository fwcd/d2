import Utils
import D2MessageIO

public class AddEventListenerCommand: RegexCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Registers an event handler",
        helpText: """
            Syntax: [event name] [listener name]

            Pipe this command into another command which is to be invoked!
            """,
        requiredPermissionLevel: .admin
    )

    public let inputPattern = #/(?<event>\S+)\s+(?<listener>\w+)/#

    private let eventListenerBus: EventListenerBus

    public init(eventListenerBus: EventListenerBus) {
        self.eventListenerBus = eventListenerBus
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        let rawEventName = String(input.event)
        let listenerName = String(input.listener)

        guard let event = EventListenerBus.Event(rawValue: rawEventName) else {
            await output.append(errorText: "Unknown event `\(rawEventName)`, try one of these: `\(EventListenerBus.Event.allCases.map { $0.rawValue })`")
            return
        }

        eventListenerBus.addListener(name: listenerName, for: event, output: output)
        _ = try? await context.channel?.send(Message(content: "Added event listener!"))
    }
}
