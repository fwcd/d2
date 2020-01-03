import SwiftDiscord
import D2Permissions
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import D2Utils
import D2NetAPIs

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
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			try UnivISQuery(search: .rooms, params: [
				.name: input
			]).start { response in
				guard case let .success(queryOutput) = response else {
					output.append("An error occurred while querying.")
					return
				}
				// Successfully received and parsed UnivIS query output
				guard let room = self.findBestMatchFor(name: input, in: queryOutput) else {
					output.append("No room was found!")
					return
				}
				guard let rawAddress = room.address else {
					output.append("Room has no address!")
					return
				}
				
				let address = self.format(rawAddress: rawAddress)
				
				self.geocoder.geocode(location: address) { geocodeResponse in
					guard case let .success(coords) = geocodeResponse else {
						output.append(rawAddress)
						return
					}
					do {
						let mapURL = try MapQuestStaticMap(
							latitude: coords.latitude,
							longitude: coords.longitude
						).url

						output.append(.embed(DiscordEmbed(
							title: address,
							url: self.googleMapsURLFor(address: address),
							image: DiscordEmbed.Image(url: URL(string: mapURL)!)
						)))
					} catch {
						output.append("Could not create static map, see console for more details")
						print(error)
					}
				}
			}
		} catch {
			print(error)
			output.append("An error occurred. Check the log for more information.")
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
