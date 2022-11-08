import Utils
import NIO

/// Represents an IO platform that is responsible for
/// sending and receiving messages, e.g. Discord.
///
/// The implementor object will be kept alive for the
/// entire application's lifetime.
public protocol MessagePlatform: Startable {
    associatedtype Token

    var name: String { get }

    /// Performs synchronous setup. This method is expected not
    /// to block and to finish quickly.
    init(
        with delegate: any MessageDelegate,
        combinedClient: CombinedMessageClient,
        eventLoopGroup: any EventLoopGroup,
        token: Token
    ) throws
}
