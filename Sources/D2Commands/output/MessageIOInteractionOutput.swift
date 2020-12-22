import Utils
import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

fileprivate let log = Logger(label: "D2Commands.MessageIOInteractionOutput")

public class MessageIOInteractionOutput: CommandOutput {
    private var context: CommandContext
    private let messageWriter = MessageWriter()
    private let onSent: (([Message]) -> Void)?

    public init(context: CommandContext, onSent: (([Message]) -> Void)? = nil) {
        self.context = context
        self.onSent = onSent
    }

    public func append(_ value: RichValue, to channel: OutputChannel) {
        guard let client = context.client else {
            log.warning("Cannot append to MessageIO without a client!")
            return
        }

        if case let .error(error, errorText: errorText) = value {
            log.warning("\(error.map { "\($0): " } ?? "")\(errorText)")
        }

        // TODO: Split/limit?
        messageWriter.write(value: value)
            .then { self.send(message: $0, with: client, to: channel) }
            .listenOrLogError { self.onSent?($0) }
    }

    private func send(message: Message, with client: MessageClient, to channel: OutputChannel) -> Promise<Message?, Error> {
        switch channel {
            case .defaultChannel:
                // TODO
                fatalError("TODO")
            default:
                return Promise(.failure(MessageIOInteractionOutputError.onlyDefaultChannelSupported))
        }
    }

    public func update(context: CommandContext) {
        self.context = context
    }
}
