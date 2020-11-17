import D2MessageIO
import D2NetAPIs
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

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let coords = input.asGeoCoordinates else {
            output.append(errorText: "Please input geographical coordinates! (You can pipe the `geocode` command into this one to look them up for a given address)")
            return
        }

        // TODO: Let user specify radius (with this one as default)
        let radius = 300 // meters

        TierVehiclesQuery(coords: coords, radius: radius).perform()
            .map(\.data)
            .then { vehicles in Promise
                .catching {
                    try MapQuestStaticMap(
                        pins: vehicles
                            .enumerated()
                            .map { (i, vehicle) in .init(
                                coords: vehicle.attributes.coords,
                                marker: "flag-md-\(vehicle.attributes.state == "ACTIVE" ? "dcffb8" : "ffe7b8")-\(i + 1)\(vehicle.attributes.batteryLevel.map { ":\($0)%25" } ?? "")"
                            ) }
                    )
                }
                .then { $0.download() }
                .map { (vehicles, $0) } }
            .listen {
                do {
                    let (vehicles, mapImageData) = try $0.get()
                    output.append(.compound([
                        .files([Message.FileUpload(data: mapImageData, filename: "vehicles.jpg", mimeType: "image/jpeg")]),
                        .embed(Embed(
                            title: ":scooter: Tier Vehicles in a Radius of \(radius)m around \(coords.latitude), \(coords.longitude)",
                            fields: vehicles.enumerated().prefix(5).map { (i, vehicle) in
                                Embed.Field(
                                    name: "Vehicle \(i + 1): \(vehicle.id)",
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
                    ]))
                } catch {
                    output.append(error, errorText: "Could not query vehicles")
                }
            }
    }
}
