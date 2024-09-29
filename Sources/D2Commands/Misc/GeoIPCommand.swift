import D2MessageIO
import D2NetAPIs
import StaticMap
import Utils

public class GeoIPCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Finds geographical information about an IP or hostname",
        helpText: "Syntax: [ip or hostname]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter an ip or hostname!")
            return
        }

        do {
            let data = try await FreeGeoIPQuery(host: input).perform()
            guard let coords = data.coords else {
                await output.append(errorText: "Did not find a location")
                return
            }

            let mapData = try await StaticMap(
                zoom: 2,
                center: coords,
                annotations: [.pin(coords: coords)]
            ).render().pngEncoded()
            let mapFileUpload = Message.FileUpload(data: mapData, filename: "map.png", mimeType: "image/png")

            await output.append(.compound([
                .files([mapFileUpload].compactMap { $0 }),
                .embed(Embed(
                    title: "GeoIP info for `\(data.ip)`",
                    fields: [
                        ("Country", data.countryName),
                        ("Region", data.regionName),
                        ("City", data.city),
                        ("Zip Code", data.zipCode),
                        ("Time Zone", data.timeZone)
                    ].compactMap { (k, v) in (v?.nilIfEmpty).map { Embed.Field(name: k, value: $0, inline: true) } }
                ))
            ]))
        } catch {
            await output.append(error, errorText: "Could not query FreeGeoIP")
        }
    }
}
