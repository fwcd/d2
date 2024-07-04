import D2MessageIO
import Foundation

public class RoboHashCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Generates a robot image from a string",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a phrase!")
            return
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "robohash.org"
        urlComponents.path = "/\(input)"

        guard let url = urlComponents.url else {
            await output.append(errorText: "Could not generate URL. Make sure not to include invalid characters!")
            return
        }

        await output.append(Embed(
            title: "Generated Robot",
            image: Embed.Image(url: url)
        ))
    }
}
