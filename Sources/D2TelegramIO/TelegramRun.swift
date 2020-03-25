import D2MessageIO
import Logging
import Telegrammer

fileprivate let log = Logger(label: "TelegramRun")

/** Runs the Telegram-based backend and blocks the thread. */
public func runTelegramIO(with delegate: MessageDelegate, combinedClient: CombinedMessageClient, token: String) {
    do {
        let bot = try Bot(token: token)
        let overlayClient = combinedClient.register(client: TelegramMessageClient(bot: bot))
        let dispatcher = Dispatcher(bot: bot)

        dispatcher.add(handler: MessageHandler { update, _ in
            guard let message = update.message else {
                log.warning("Update did not contain message")
                return
            }
            log.info("Got message '\(message.text)'")
            delegate.on(createMessage: message.usingMessageIO, client: overlayClient)
        })
        
        _ = try Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()
    } catch {
        log.warning("Could not create Telegram bot: \(error)")
    }
}
