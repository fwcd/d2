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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter something to search for!")
            return
        }

        let gifPromise = GiphySearchQuery(term: input)
            .perform()
            .mapCatching { (results: GiphyResults) -> GiphyResults.GIF in
                guard let gif = results.data.first else { throw GiphyError.noGIFsFound }
                return gif
            }

        if downloadGifs {
            gifPromise
                .then { $0.download() }
                .mapCatching { try GIF(data: $0) }
                .listen {
                    do {
                        output.append(.gif(try $0.get()))
                    } catch {
                        output.append(error, errorText: "Could not query/download GIF")
                    }
                }
        } else {
            gifPromise
                .listen {
                    do {
                        output.append(.urls([try $0.get().url]))
                    } catch {
                        output.append(error, errorText: "Could not query GIF")
                    }
                }
        }
    }

    private enum GiphyError: Error {
        case noGIFsFound
    }
}
