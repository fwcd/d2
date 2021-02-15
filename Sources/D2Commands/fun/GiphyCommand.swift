import D2NetAPIs
import D2MessageIO
import GIF

public class GiphyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Fetches a GIF from Giphy",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter something to search for!")
            return
        }

        GiphySearchQuery(term: input)
            .perform()
            .thenCatching {
                guard let gif = $0.data.first else { throw GiphyError.noGIFsFound }
                return gif.download()
            }
            .mapCatching { try GIF(data: $0) }
            .listen {
                do {
                    output.append(.gif(try $0.get()))
                } catch {
                    output.append(error, errorText: "Could not query GIF")
                }
            }
    }

    private enum GiphyError: Error {
        case noGIFsFound
    }
}
