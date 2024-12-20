import D2MessageIO
import D2Permissions
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging
import StaticMap
import Utils
import D2NetAPIs

private let log = Logger(label: "D2Commands.CampusCommand")
nonisolated(unsafe) private let addressWithCityPattern = #/.+,\s*\d\d\d\d\d\s+\w+/#

/// Locates locations on the University of Kiel's campus.
public class CampusCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Locates rooms on the CAU campus",
        longDescription: "Looks up room abbreviations (such as 'LMS4') in this UnivIS and outputs the address together with a static street map",
        presented: true,
        requiredPermissionLevel: .basic
    )
    let geocoder = NominatimGeocoder()

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let query = try UnivISQuery(search: .rooms, params: [.name: input])
            let queryOutput = try await query.perform()

            // Successfully received and parsed UnivIS query output
            guard let room = self.findBestMatchFor(name: input, in: queryOutput) else {
                throw CampusCommandError.noRoomFound
            }
            log.info("Found room \(room)")

            guard let rawAddress = room.address else {
                throw CampusCommandError.roomHasNoAddress("\(room)")
            }
            log.info("Found address \(rawAddress)")

            let address = self.normalize(rawAddress: rawAddress)
            log.info("Normalized address to \(address)")

            let coords = try await geocoder.geocode(location: address)
            log.info("Geocoded address to \(coords)")

            await output.append(.compound([
                .geoCoordinates(coords),
                .embed(Embed(
                    title: address,
                    url: self.googleMapsURLFor(address: address)
                ))
            ]))
        } catch {
            await output.append(error, errorText: "Could not create static map: `\(error)`")
        }
    }

    private func findBestMatchFor(name: String, in output: UnivISOutputNode) -> UnivISRoom? {
        return output.childs
            .compactMap { $0 as? UnivISRoom }
            .sorted { matchRatingFor(room: $0, name: name) > matchRatingFor(room: $1, name: name) }
            .first
    }

    private func matchRatingFor(room: UnivISRoom, name: String) -> Int {
        return ((room.short?.starts(with: "\(name) ") ?? false) ? 1 : 0)
            + ((room.address != nil) ? 2 : 0)
    }

    private func normalize(rawAddress: String) -> String {
        var address: String = rawAddress.replacingOccurrences(of: "str.", with: "straße")

        if rawAddress.matches(of: addressWithCityPattern).isEmpty {
            address = address.split(separator: #/[,(]/#).first! + ", 24118 Kiel"
        }

        return address
    }

    private func googleMapsURLFor(address: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.google.com"
        components.path = "/maps/place/\(address)"
        return components.url!
    }
}
