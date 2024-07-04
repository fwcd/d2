import D2NetAPIs
import D2MessageIO

public class BeerCommand: StringCommand {
    public let info = CommandInfo(
        category: .food,
        shortDescription: "Fetches a random beer from BrewDog's DIY Dog",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            guard let beer = try await PunkAPIQuery().perform().randomElement() else {
                await output.append(errorText: "No results found")
                return
            }
            await output.append(Embed(
                title: ":beer: \(beer.name)",
                description: beer.description,
                thumbnail: beer.imageUrl.map(Embed.Thumbnail.init(url:)),
                footer: beer.tagline.map(Embed.Footer.init(text:))
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch beer")
        }
    }
}
