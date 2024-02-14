import D2NetAPIs
import D2MessageIO

public class SunriseSunsetCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Finds the sunrise/sunset at a given location",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let coords = input.asGeoCoordinates else {
            output.append(errorText: "Please input geographical coordinates, e.g. by piping the command `geo` into this one!")
            return
        }

        SunriseSunsetQuery(at: coords).perform().listen {
            do {
                let results = try $0.get().results
                output.append(Embed(
                    title: ":sun_with_face: Sunrise/Sunset at \(coords.latitude), \(coords.longitude)",
                    fields: ([
                        (":sunrise: Sunrise", results.sunrise),
                        (":city_sunset: Sunset", results.sunset),
                        (":sunny: Solar Noon", results.solarNoon),
                        (":calendar: Day Length", results.dayLength)
                    ] + [
                        (":city_dusk: Civil Twilight", results.civilTwilightBegin, results.civilTwilightEnd),
                        (":sailboat: Nautical Twilight", results.nauticalTwilightBegin, results.nauticalTwilightEnd),
                        (":ringed_planet: Astronomical Twilight", results.astronomicalTwilightBegin, results.astronomicalTwilightEnd)
                    ].map { (k, v1, v2) in (k, v1.flatMap { b in v2.map { e in "Begin: \(b)\nEnd: \(e)" } }) })
                    .compactMap { (k, v) in v.map { Embed.Field(name: k, value: $0, inline: true) } }
                ))
            } catch {
                output.append(error, errorText: "Could not query sunrise/sunset")
            }
        }
    }
}
