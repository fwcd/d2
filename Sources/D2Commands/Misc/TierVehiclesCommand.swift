import D2MessageIO
import D2NetAPIs
@preconcurrency import Graphics
import StaticMap
import Utils

public class TierVehiclesCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Finds tier vehicles near a given position",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .geoCoordinates
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let coords = input.asGeoCoordinates else {
            await output.append(errorText: "Please input geographical coordinates! (You can pipe the `geocode` command into this one to look them up for a given address)")
            return
        }

        // TODO: Let user specify radius (with this one as default)
        let radius = 300 // meters

        do {
            let vehicles = try await TierVehiclesQuery(coords: coords, radius: radius).perform().data

            guard !vehicles.isEmpty else {
                await output.append(errorText: "No vehicles found")
                return
            }

            let activeColor = Color(rgb: 0x498f00)
            let inactiveColor = Color.gray
            let map = StaticMap(
                annotations: vehicles
                    .enumerated()
                    .map { (i, vehicle) in
                        .pin(coords: vehicle.attributes.coords)
                            .color(vehicle.attributes.state == "ACTIVE" ? activeColor : inactiveColor)
                            .label("\(i + 1)\(vehicle.attributes.batteryLevel.map { ":\($0)%25" } ?? "")")
                    }
            )
            let mapImageData = try await map.render().pngEncoded()
            await output.append(.compound([
                .files([Message.FileUpload(data: mapImageData, filename: "vehicles.png", mimeType: "image/png")]),
                .embed(Embed(
                    title: ":scooter: Tier Vehicles in a Radius of \(radius)m around \(coords.latitude), \(coords.longitude)",
                    fields: vehicles
                        .enumerated()
                        .prefix(5)
                        .map { (i, vehicle) in
                            let attributes = vehicle.attributes
                            let badges = [
                                attributes.hasHelmet.filter { $0 }.map { _ in ":military_helmet:" },
                                attributes.hasHelmetBox.filter { $0 }.map { _ in ":toolbox:" },
                                attributes.isRentable.filter { $0 }.map { _ in ":dollar:" },
                            ].compactMap { $0 }.joined(separator: " ")

                            return Embed.Field(
                                name: "Vehicle \(i + 1): \(attributes.state) (\(attributes.batteryLevel.map(String.init) ?? "?")%) \(badges)".trimmingCharacters(in: .whitespacesAndNewlines),
                                value: [
                                    ("Max Speed", attributes.maxSpeed.map { "\($0) km/h" }),
                                    ("License Plate", attributes.licensePlate),
                                    ("ID", vehicle.id)
                                ]
                                    .compactMap { (k, v) in v.map { "\(k): \($0)" } }
                                    .joined(separator: "\n")
                                    .nilIfEmpty ?? "_no attributes_"
                            )
                        }
                ))
            ]))
        } catch {
            await output.append(error, errorText: "Could not query vehicles")
        }
    }
}
