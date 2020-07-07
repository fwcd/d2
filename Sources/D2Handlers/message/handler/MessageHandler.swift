import D2MessageIO

/**
 * Represents anything that receives/handles incoming Discord messages.
 *
 * Handlers are usually arranged in a "chain of responsibility" where
 * the first successful handler stops propagation of the message.
 */
public protocol MessageHandler {
    /**
     * Processes the message and returns whether it was handled (successfully).
     * Handlers can also return false if they only "observed" the message, but
     * did not intend to "consume" it.
     */
    mutating func handle(message: Message, from client: MessageClient) -> Bool

    /**
     * Processes the raw (non-rewritten) message and returns whether it was handled
     * (sucessfully). This method will always be invoked prior to the actual handle
     * method.
     *
     * Generally, you should avoid implementing this method unless you have a good
     * reason to do so, since this may cause unintended message semantics.
     */
    mutating func handleRaw(message: Message, from client: MessageClient) -> Bool
}

public extension MessageHandler {
    func handle(message: Message, from client: MessageClient) -> Bool { false }

    func handleRaw(message: Message, from client: MessageClient) -> Bool { false }
}
