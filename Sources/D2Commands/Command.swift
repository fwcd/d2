import D2MessageIO
import D2Permissions

/** Encapsulates functionality that can conveniently be invoked using inputs and arguments. */
public protocol Command: class {
    var inputValueType: RichValueType { get }
    var outputValueType: RichValueType { get }
    var info: CommandInfo { get }

    func invoke(with input: RichValue, output: CommandOutput, context: CommandContext)

    func onSuccessfullySent(context: CommandContext)

    func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext)

    func onSubscriptionReaction(emoji: Emoji, by user: User, output: CommandOutput, context: CommandContext)

    func onReceivedUpdated(presence: Presence)

    func equalTo(_ rhs: Command) -> Bool
}

extension Command {
    public var inputValueType: RichValueType { .unknown }
    public var outputValueType: RichValueType { .unknown }

    public func onSuccessfullySent(context: CommandContext) {}

    public func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext) {}

    public func onSubscriptionReaction(emoji: Emoji, by user: User, output: CommandOutput, context: CommandContext) {}

    // TODO: Support reaction removal

    public func onReceivedUpdated(presence: Presence) {}

    public func equalTo(_ rhs: Command) -> Bool { self === rhs }
}
