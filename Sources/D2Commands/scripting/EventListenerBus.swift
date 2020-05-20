public class EventListenerBus {
    /// Maps events to listeners
    private var listeners: [Event: [Listener]] = [:]

    public init() {}

    private struct Listener {
        let name: String
        let output: CommandOutput
    }

    public enum Event: String, CaseIterable {
        case messageCreate = "message.create"
    }

    public func fire(event: Event, with input: RichValue) {
        for listener in listeners[event] ?? [] {
            listener.output.append(input)
        }
    }

    public func addListener(name: String, for event: Event, output: CommandOutput) {
        if !listeners.keys.contains(event) {
            listeners[event] = []
        }
        listeners[event]!.append(Listener(name: name, output: output))
    }

    public func removeListener(name: String) {
        for key in listeners.keys {
            listeners[key]!.removeAll(where: { $0.name == name })
        }
    }
}