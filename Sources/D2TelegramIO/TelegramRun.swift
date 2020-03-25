import D2MessageIO
import Logging
import Telegrammer

fileprivate let log = Logger(label: "D2TelegramIO.TelegramRun")

/** Runs the Telegram-based backend and blocks the thread. */
public func runTelegramIO(with delegate: MessageDelegate, combinedClient: CombinedMessageClient, token: String) {
    do {
        log.info("Running Telegram backend...")
        let bot = try Bot(token: token)
        let overlayClient = combinedClient.register(client: TelegramMessageClient(bot: bot))
        let dispatcher = Dispatcher(bot: bot)

        log.info("Adding message handler to dispatcher")
        dispatcher.add(handler: MessageHandler { update, _ in
            guard let message = update.message else {
                log.warning("Update did not contain message")
                return
            }
            log.info("Got message '\(message.text ?? "")'")
            delegate.on(createMessage: message.usingMessageIO, client: overlayClient)
        })
        
        log.info("Starting longpolling")
        _ = try Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()
    } catch {
        log.warning("Could not create Telegram bot: \(error)")
    }
}
