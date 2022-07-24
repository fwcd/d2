import D2MessageIO
import D2NetAPIs

public class NasaAstronomyPictureOfTheDayCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches NASA's Astronomy Picture of the Day",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        NasaAstronomyPictureOfTheDayQuery().perform().listen {
            do {
                let result = try $0.get()
                output.append(Embed(
                    title: result.title,
                    image: Embed.Image(url: result.hdurl)
                ))
            } catch {
                output.append(error, errorText: "Could not fetch picture of the day")
            }
        }
    }
}
