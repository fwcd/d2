import D2MessageIO

/// A central facility where commands (possibly with aliases)
/// can be registered.
@CommandActor
public class CommandRegistry {
    /// The registered commands and aliases. It is assumed that
    /// every alias (possibly being nested) points to a valid
    /// command and neither dangles nor cycles.
    public private(set) var entries = [String: Entry]()

    public init() {}

    public enum Entry: Sendable {
        case command(any Command)
        case alias(String)

        var asCommand: (any Command)? {
            switch self {
                case .command(let cmd): cmd
                default: nil
            }
        }
    }

    private func resolve(_ name: String) -> String {
        switch entries[name] {
            case .alias(let a)?: resolve(a)
            default: name
        }
    }

    public subscript(_ name: String, aka aliases: [String]) -> Command? {
        get { entries[resolve(name.lowercased())]?.asCommand }
        set {
            // TODO: Support unregistration by correctly removing aliases
            // TODO: Enforce invariants when encountering overlapping aliases
            guard let value = newValue else { fatalError("Command unregistration is not yet supported") }
            entries[name.lowercased()] = .command(value)
            for alias in aliases {
                entries[alias] = .alias(name.lowercased())
            }
        }
    }

    public subscript(_ name: String) -> Command? {
        get { self[name, aka: []] }
        set { self[name, aka: []] = newValue }
    }

    public struct CommandWithAlias: Sendable {
        public let name: String
        public let aliases: [String]
        public let command: any Command
    }

    public func commandsWithAliases() -> [CommandWithAlias] {
        let dict = Dictionary(grouping: entries, by: { resolve($0.0) })
        return dict.map { (name, ents) in CommandWithAlias(
            name: name,
            aliases: ents.map { $0.0 }.filter { name != $0 },
            command: ents.compactMap { $0.1.asCommand }.first! // Dict cannot contain aliases that point to no command
        ) }
    }
}
