import D2MessageIO
import D2Utils
import D2Graphics

/// A sink for rich values.
public protocol CommandOutput {
    var messageLengthLimit: Int? { get }

    func append(_ value: RichValue, to channel: OutputChannel)

    /// Updates the internal context of the output. Should only
    /// be used if the CommandOutput if retained beyond the original
    /// message invocation (e.g. when registering event listeners).
    func update(context: CommandContext)
}

public extension CommandOutput {
    var messageLengthLimit: Int? { return nil }

    func append(_ value: RichValue) {
        append(value, to: .defaultChannel)
    }

    func append(_ str: String, to channel: OutputChannel = .defaultChannel) {
        append(.text(str), to: channel)
    }

    func append(_ embed: Embed, to channel: OutputChannel = .defaultChannel) {
        append(.embed(embed), to: channel)
    }

    func append(_ image: Image, name: String? = nil, to channel: OutputChannel = .defaultChannel) throws {
        append(.image(image), to: channel)
    }

    func append(_ files: [Message.FileUpload], to channel: OutputChannel = .defaultChannel) {
        append(.files(files), to: channel)
    }

    func append(errorText: String, to channel: OutputChannel = .defaultChannel) {
        append(.error(nil, errorText: errorText), to: channel)
    }

    func append(_ error: Error, errorText: String = "An error occurred in \(#file)", to channel: OutputChannel = .defaultChannel) {
        append(.error(error, errorText: errorText), to: channel)
    }

    func append(_ result: Result<RichValue, Error>, errorText: String = "An error occurred in \(#file)", to channel: OutputChannel = .defaultChannel) {
        switch result {
            case .success(let value):
                append(value, to: channel)
            case .failure(let error):
                append(error, errorText: errorText, to: channel)
        }
    }
}
