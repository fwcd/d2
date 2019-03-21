import Sword

class CampusCommand: Command {
	let description = "Locates rooms on the CAU campus"
	let requiredPermissionLevel = PermissionLevel.basic
	let geocoder = MapQuestGeocoder()
	
	func invoke(withMessage message: Message, args: String) {
		do {
			try UnivISQuery(scheme: univISCAUScheme, host: univISCAUHost, path: univISCAUPath, search: .rooms, params: [
				.name: args
			]).start { response in
				guard case let .ok(output) = response else {
					message.channel.send("An error occurred while querying.")
					return
				}
				// Successfully received and parsed UnivIS query output
				guard let room = (output.childs.first { $0 is UnivISRoom }.map { $0 as! UnivISRoom }) else {
					message.channel.send("No room was found!")
					return
				}
				guard let address = room.address else {
					message.channel.send("Room has no address!")
					return
				}
				
				self.geocoder.geocode(location: address) { geocodeResponse in
					guard case let .ok(coords) = geocodeResponse else {
						message.channel.send(address)
						return
					}
					let mapURL = MapQuestStaticMap(
						latitude: coords.latitude,
						longitude: coords.longitude
					).url
					
					message.channel.send([
						.file: mapURL,
						.content: address
					])
				}
			}
		} catch {
			print(error)
			message.channel.send("An error occurred. Check the log for more information.")
		}
	}
}
