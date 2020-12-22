import Utils
import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

fileprivate let log = Logger(label: "D2Commands.MessageIOInteractionOutput")

public class MessageIOInteractionOutput: CommandOutput {
    private let interaction: Interaction
    private var context: CommandContext
    private let messageWriter = MessageWriter()

    public init(interaction: Interaction, context: CommandContext) {
        self.interaction = interaction
        self.context = context
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
            .listenOrLogError { _ in }
    }

    private func send(message: Message, with client: MessageClient, to channel: OutputChannel) -> Promise<Bool, Error> {
        switch channel {
            case .defaultChannel:
                guard let token = interaction.token else {
                    return Promise(.failure(MessageIOInteractionOutputError.noInteractionToken))
                }
                let response = InteractionResponse(type: .channelMessageWithSource, data: message)
                return client.createInteractionResponse(for: interaction.id, token: token, response: response)
            default:
                return Promise(.failure(MessageIOInteractionOutputError.onlyDefaultChannelSupported))
        }
    }

    public func update(context: CommandContext) {
        self.context = context
    }
}
