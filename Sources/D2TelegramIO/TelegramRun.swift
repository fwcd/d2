import D2MessageIO
import TelegramBotSDK

/** Runs the Telegram-based backend and blocks the thread. */
public func runTelegramIO(with delegate: MessageDelegate, combinedClient: CombinedMessageClient, token: String) {
    let bot = TelegramBot(token: token)

    combinedClient.register(client: TelegramMessageClient(bot: bot))

    while let update = bot.nextUpdateSync() {
        // TODO
        // delegate.on(createMessage: update.message.usingTelegramAPI, client: combinedClient)
    }
}
