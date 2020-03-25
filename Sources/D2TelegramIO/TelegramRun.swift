import D2MessageIO
import TelegramBotSDK

/** Runs the Telegram-based backend and blocks the thread. */
public func runTelegramIO(with delegate: MessageDelegate, combinedClient: CombinedMessageClient, token: String) {
    let bot = TelegramBot(token: token)
    let overlayClient = combinedClient.register(client: TelegramMessageClient(bot: bot))

    while let update = bot.nextUpdateSync() {
        if let message = update.message {
            delegate.on(createMessage: message.usingMessageIO, client: overlayClient)
        }
    }
}
