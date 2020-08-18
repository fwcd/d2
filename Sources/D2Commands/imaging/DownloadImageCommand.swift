import D2Utils
import D2Graphics

public class DownloadImageCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Downloads an image from a URL",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let urls = input.asUrls else {
            output.append(errorText: "Not a URL")
            return
        }
        guard urls.allSatisfy({ $0.path.hasSuffix(".png") }) else {
            output.append(errorText: "Only PNG images are currently supported")
            return
        }

        sequence(promises: urls.map { url in { HTTPRequest(url: url).fetchPNGAsync() } }).listen {
            do {
                try output.append(.compound($0.get().map { RichValue.image($0) }))
            } catch {
                output.append(error, errorText: "Could not download image(s)")
            }
        }
    }
}
