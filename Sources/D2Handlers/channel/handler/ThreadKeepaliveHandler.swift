import D2MessageIO
import D2Commands
import Utils
import Logging

fileprivate let log = Logger(label: "D2Handlers.ThreadKeepaliveHandler")

public struct ThreadKeepaliveHandler: ChannelHandler {
    @AutoSerializing private var config: ThreadConfiguration

    public init(config _config: AutoSerializing<ThreadConfiguration>) {
        self._config = _config
    }

    public func handle(threadUpdate thread: Channel, client: MessageClient) {
        log.info("Thread \(thread.name) has archival status: \(thread.threadMetadata?.archived ?? false)")

        let archived = thread.threadMetadata?.archived ?? false
        let locked = thread.threadMetadata?.locked ?? true

        if archived {
            guard !locked else {
                log.debug("Ignoring '\(thread.name)''s archival since it is locked")
                return
            }
            guard let parentId = thread.parentId, config.keepaliveParentChannelIds.contains(parentId) else {
                log.info("Ignoring '\(thread.name)''s archival since its parent is not in the keepalives")
                return
            }
            guard config.permanentlyArchivedThreadIds.contains(thread.id) else {
                log.info("Ignoring '\(thread.name)''s archival since its permanently archived")
                return
            }

            log.info("Unarchiving '\(thread.name)'")
            client.modifyChannel(thread.id, with: .init(archived: false))
        }
    }
}
