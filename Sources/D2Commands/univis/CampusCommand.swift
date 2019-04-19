import SwiftDiscord
import D2Permissions
import Foundation
import D2Utils
import D2WebAPIs

fileprivate let addressWithCityPattern = try! Regex(from: ".+,\\s*\\d\\d\\d\\d\\d\\s+\\w+")

/** Locates locations on the University of Kiel's campus. */
public class CampusCommand: StringCommand {
	public let description = "Locates rooms on the CAU campus"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
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
						
						URLSession.shared.dataTask(with: URL(string: mapURL)!) { data, response, error in
							guard error == nil else {
								output.append("An error occurred while fetching image.")
								return
							}
							guard let data = data else {
								output.append("Missing data while fetching image.")
								return
							}
							
							output.append(DiscordMessage(
								content: rawAddress,
								files: [DiscordFileUpload(data: data, filename: "map.png", mimeType: "image/png")]
							))
						}.resume()
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
}
