import D2NetAPIs
import D2MessageIO

public class BeerCommand: StringCommand {
    public let info = CommandInfo(
        category: .food,
        shortDescription: "Fetches a random beer from BrewDog's DIY Dog",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        PunkAPIQuery().perform().listen {
            do {
                guard let beer = try $0.get().randomElement() else {
                    output.append(errorText: "No results found")
                    return
                }
                output.append(Embed(
                    title: ":beer: \(beer.name)",
                    description: beer.description,
                    thumbnail: beer.imageUrl.map(Embed.Thumbnail.init(url:)),
                    footer: beer.tagline.map(Embed.Footer.init(text:))
                ))
            } catch {
                output.append(error, errorText: "Could not fetch beer")
            }
        }
    }
}
