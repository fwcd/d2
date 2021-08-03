import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.ThreadKeepaliveHandler")

public struct ThreadKeepaliveHandler: ChannelHandler {
    public func handle(threadUpdate thread: Channel, client: MessageClient) {
        log.info("Thread \(thread.name) has archival status: \(thread.threadMetadata?.archived ?? false)")

        // TODO: Unarchive the thread automatically, ideally add a configuration
        // so users can add permanently to-be-archived threads through a command
    }
}
