import D2Utils

public class RemoveEventListenerCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Deregisters an event handler",
        helpText: "Syntax: [listener name]",
        requiredPermissionLevel: .admin
    )
    private let eventListenerBus: EventListenerBus

    public init(eventListenerBus: EventListenerBus) {
        self.eventListenerBus = eventListenerBus
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        eventListenerBus.removeListener(name: input)
        output.append("Removed listener (if present)!")
    }
}
