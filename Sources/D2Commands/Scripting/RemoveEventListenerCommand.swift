import Utils

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        eventListenerBus.removeListener(name: input)
        await output.append("Removed listener (if present)!")
    }
}
