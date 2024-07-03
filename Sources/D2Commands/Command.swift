import D2MessageIO
import D2Permissions

/// Encapsulates functionality that can conveniently be invoked using rich-valued inputs.
public protocol Command: AnyObject {
    /// The input that this command expects to be invoked with. Note that this is purely
    /// an annotation for documentary purposes and not enforced at runtime.
    var inputValueType: RichValueType { get }
    /// The output that this command is expected to emit. Note that this is purely
    /// an annotation for documentary purposes and not enforced at runtime.
    var outputValueType: RichValueType { get }
    /// Metadata about the command.
    var info: CommandInfo { get }

    /// Invokes the command.
    ///
    /// Command invocations are inherently effectful and often asynchronous. This means
    /// that the passed output may be invoked on any thread, zero or (arbitrary) more times.
    func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async

    /// Notifies the command that a message sent via CommandOutput has been
    /// successfully transmitted.
    func onSuccessfullySent(context: CommandContext) async

    /// Notifies the command that a message on a subscribed channel has arrived.
    func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async

    /// Notifies the command that a component interaction on a subscribed channel has arrived.
    func onSubscriptionInteraction(with customId: String, by user: User, output: any CommandOutput, context: CommandContext) async

    /// Notifies the command that a reaction on a subscribed channel has arrived.
    func onSubscriptionReaction(emoji: Emoji, by user: User, output: any CommandOutput, context: CommandContext) async

    /// Notifies the command that the bot's presence has updated.
    func onReceivedUpdated(presence: Presence) async
}

extension Command {
    public var inputValueType: RichValueType { .unknown }
    public var outputValueType: RichValueType { .unknown }

    public func onSuccessfullySent(context: CommandContext) async {}

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async {}

    public func onSubscriptionInteraction(with customId: String, by user: User, output: any CommandOutput, context: CommandContext) async {}

    public func onSubscriptionReaction(emoji: Emoji, by user: User, output: any CommandOutput, context: CommandContext) async {}

    // TODO: Support reaction removal

    public func onReceivedUpdated(presence: Presence) async {}
}
