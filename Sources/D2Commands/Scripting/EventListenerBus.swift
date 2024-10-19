@CommandActor
public class EventListenerBus {
    /// Maps events to listeners
    private var listeners: [Event: [Listener]] = [:]

    public init() {}

    private struct Listener: Sendable {
        let name: String
        let output: any CommandOutput
    }

    public enum Event: String, CaseIterable, Sendable {
        case connect
        case createChannel
        case deleteChannel
        case updateChannel
        case createGuild
        case deleteGuild
        case updateGuild
        case addGuildMember
        case removeGuildMember
        case updateGuildMember
        case updateMessage
        case createMessage
        case createRole
        case deleteRole
        case updateRole
        case receivePresenceUpdate
        case receiveReady
        case receiveVoiceStateUpdate
        case handleGuildMemberChunk
        case updateEmojis
    }

    public func fire(event: Event, with input: RichValue, context: CommandContext? = nil) async {
        for listener in listeners[event] ?? [] {
            if let c = context {
                await listener.output.update(context: c)
            }
            await listener.output.append(input)
        }
    }

    public func addListener(name: String, for event: Event, output: any CommandOutput) {
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
