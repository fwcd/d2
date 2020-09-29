import D2MessageIO
import D2Permissions
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging
import Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.CampusCommand")
fileprivate let addressWithCityPattern = try! Regex(from: ".+,\\s*\\d\\d\\d\\d\\d\\s+\\w+")

/** Locates locations on the University of Kiel's campus. */
public class CampusCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Locates rooms on the CAU campus",
        longDescription: "Looks up room abbreviations (such as 'LMS4') in this UnivIS and outputs the address together with a static street map",
        requiredPermissionLevel: .basic
    )
    let geocoder = MapQuestGeocoder()

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        Promise.catching { try UnivISQuery(search: .rooms, params: [.name: input]) }
            .then { $0.start() }
            .thenCatching { (queryOutput: UnivISOutputNode) throws -> Promise<Embed, Error> in
                // Successfully received and parsed UnivIS query output
                guard let room = self.findBestMatchFor(name: input, in: queryOutput) else {
                    throw CampusCommandError.noRoomFound
                }
                guard let rawAddress = room.address else {
                    throw CampusCommandError.roomHasNoAddress("\(room)")
                }

                let address = self.format(rawAddress: rawAddress)

                return self.geocoder.geocode(location: address)
                    .mapCatching { coords in
                        try MapQuestStaticMap(
                            latitude: coords.latitude,
                            longitude: coords.longitude
                        ).url
                    }
                    .map { mapURL in
                        Embed(
                            title: address,
                            url: self.googleMapsURLFor(address: address),
                            image: Embed.Image(url: URL(string: mapURL)!)
                        )
                    }
            }
            .listen {
                do {
                    let embed = try $0.get()
                    output.append(embed)
                } catch {
                    output.append(error, errorText: "Could not create static map: `\(error)`")
                }
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

    private func format(rawAddress: String) -> String {
        var address: String = rawAddress.replacingOccurrences(of: "str.", with: "straße")

        if addressWithCityPattern.matchCount(in: rawAddress) == 0 {
            address = address.split(separator: ",").first! + ", 24118 Kiel"
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
