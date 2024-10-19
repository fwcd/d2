import D2Commands
import D2MessageIO

/// Anything that handles presence changes from
/// someone on Discord.
@CommandActor
public protocol PresenceHandler {
    /// Handles a single presence update. Is invoked
    /// for each presence after connecting.
    mutating func handle(presenceUpdate presence: Presence, sink: any Sink) async
}
