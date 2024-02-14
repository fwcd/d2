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

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
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
                                marker: [
                                    "flag", // type
                                    "sm", // size
                                    "000000", // bg color
                                    vehicle.attributes.state == "ACTIVE" ? "dcffb8" : "ffe7b8", // fg color
                                    "\(i + 1)\(vehicle.attributes.batteryLevel.map { ":\($0)%25" } ?? "")" // text
                                ].joined(separator: "-")
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
                    output.append(error, errorText: "Could not query vehicles")
                }
            }
    }
}
