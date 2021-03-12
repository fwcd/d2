import D2MessageIO
import D2NetAPIs

public class GeoIPCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Finds geographical information about an IP or hostname",
        helpText: "Syntax: [ip or hostname]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter an ip or hostname!")
            return
        }

        FreeGeoIPQuery(host: input).perform().listen {
            do {
                let data = try $0.get()
                let map = data.coords.flatMap {
                    try? MapQuestStaticMap(center: $0, zoom: 2)
                }?.url

                output.append(Embed(
                    title: "GeoIP info for `\(data.ip)`",
                    image: map.map(Embed.Image.init(url:)),
                    fields: [
                        ("Country", data.countryName),
                        ("Region", data.regionName),
                        ("City", data.city),
                        ("Zip Code", data.zipCode),
                        ("Time Zone", data.timeZone)
                    ].compactMap { (k, v) in (v?.nilIfEmpty).map { Embed.Field(name: k, value: $0, inline: true) } }
                ))
            } catch {
                output.append(error, errorText: "Could not query FreeGeoIP")
            }
        }
    }
}
