import D2MessageIO
import Logging
import Telegrammer

fileprivate let log = Logger(label: "D2TelegramIO.TelegramPlatform")

public struct TelegramPlatform: MessagePlatform {
    private let bot: Bot
    private let dispatcher: Dispatcher

    public var name: String { telegramClientName }

    public init(with delegate: any MessageDelegate, combinedClient: CombinedMessageClient, token: String) throws {
        log.info("Initializing Telegram backend...")
        bot = try Bot(token: token)
        let overlayClient = combinedClient.register(client: TelegramMessageClient(bot: bot))

        log.info("Setting up dispatcher")
        dispatcher = Dispatcher(bot: bot)
        dispatcher.add(handler: MessageHandler { update, _ in
            guard let message = update.message else {
                log.warning("Update did not contain message")
                return
            }
            log.info("Got message '\(message.text ?? "")'")
            delegate.on(createMessage: message.usingMessageIO, client: overlayClient)
        })
    }

    public func start() throws {
        log.info("Starting longpolling")
        _ = try Updater(bot: bot, dispatcher: dispatcher).startLongpolling()
    }
}
