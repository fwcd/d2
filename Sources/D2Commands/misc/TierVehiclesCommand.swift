import D2MessageIO
import D2NetAPIs

public class TierVehiclesCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Finds tier vehicles near a given position",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .geoCoordinates
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let coords = input.asGeoCoordinates else {
            output.append(errorText: "Please input geographical coordinates! (You can pipe the `geocode` command into this one to look them up for a given address)")
            return
        }

        TierVehiclesQuery(coords: coords).perform().listen {
            do {
                let vehicles = try $0.get().data
                output.append(Embed(
                    title: ":scooter: Tier Vehicles near \(coords.latitude), \(coords.longitude)",
                    fields: vehicles.prefix(5).map { vehicle in
                        Embed.Field(
                            name: "\(vehicle.attributes.vehicleType ?? vehicle.type) \(vehicle.id)",
                            value: [
                                ("State", vehicle.attributes.state),
                                ("Battery Level", vehicle.attributes.batteryLevel.map(String.init)),
                                ("Latitude", String(vehicle.attributes.lat)),
                                ("Longitude", String(vehicle.attributes.lng)),
                                ("Max Speed", vehicle.attributes.maxSpeed.map(String.init)),
                                ("License Plate", vehicle.attributes.licensePlate),
                                ("Has Helmet", vehicle.attributes.hasHelmet.map(String.init))
                            ]
                                .compactMap { (k, v) in v.map { "\(k): \($0)" } }
                                .joined(separator: "\n")
                                .nilIfEmpty ?? "_no attributes_"
                        )
                    }
                ))
            } catch {
                output.append(error, errorText: "Could not query vehicles")
            }
        }
    }
}
