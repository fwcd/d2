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

    public func append(_ value: RichValue, to channel: OutputChannel) async {
        guard let sink = context.sink else {
            log.warning("Cannot append to MessageIO without a client!")
            return
        }

        if case let .error(error, errorText: errorText) = value {
            log.warning("\(error.map { "\($0): " } ?? "")\(errorText)")
        }

        // TODO: Split/limit?
        do {
            let message = try await messageWriter.write(value: value)
            try await self.send(message: message, with: sink, to: channel)
        } catch {
            log.error("Interaction output failed: \(error)")
        }
    }

    private func send(message: Message, with sink: any Sink, to channel: OutputChannel) async throws {
        switch channel {
            case .defaultChannel:
                guard let token = interaction.token else {
                    throw MessageIOInteractionOutputError.noInteractionToken
                }
                let response = InteractionResponse(type: .channelMessageWithSource, data: message)
                return try await sink.createInteractionResponse(for: interaction.id, token: token, response: response)
            default:
                throw MessageIOInteractionOutputError.onlyDefaultChannelSupported
        }
    }

    public func update(context: CommandContext) {
        self.context = context
    }
}
