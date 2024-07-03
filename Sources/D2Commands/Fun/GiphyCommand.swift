import D2NetAPIs
import D2MessageIO
import GIF

public class GiphyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Fetches a GIF from Giphy",
        requiredPermissionLevel: .basic
    )
    private let downloadGifs: Bool

    public init(downloadGifs: Bool = false) {
        // TODO: Enable once GIF decoding is more stable
        self.downloadGifs = downloadGifs
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter something to search for!")
            return
        }

        do {
            let results = try await GiphySearchQuery(term: input).perform().get()
            guard let gif = results.data.first else { throw GiphyError.noGIFsFound }

            if downloadGifs {
                let data = try await gif.download()
                await output.append(.gif(try GIF(data: data)))
            } else {
                await output.append(.urls([gif.url]))
            }
        } catch {
            await output.append(error, errorText: "Could not query/download GIF")
        }
    }

    private enum GiphyError: Error {
        case noGIFsFound
    }
}
