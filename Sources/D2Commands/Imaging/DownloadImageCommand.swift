import Utils
import CairoGraphics

public class DownloadImageCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Downloads an image from a URL",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let urls = input.asUrls else {
            await output.append(errorText: "Not a URL")
            return
        }
        guard urls.allSatisfy({ $0.path.hasSuffix(".png") }) else {
            await output.append(errorText: "Only PNG images are currently supported")
            return
        }

        do {
            let values = try await withThrowingTaskGroup(of: CairoImage.self) { group in
                for url in urls {
                    group.addTask {
                        try await HTTPRequest(url: url).fetchPNG()
                    }
                }

                var values: [RichValue] = []
                for try await image in group {
                    values.append(.image(image))
                }
                return values
            }
            await output.append(.compound(values))
        } catch {
            await output.append(error, errorText: "Could not download image(s)")
        }
    }
}
