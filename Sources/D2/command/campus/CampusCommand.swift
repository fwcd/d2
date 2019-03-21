import Sword

class CampusCommand: Command {
	let description = "Locates rooms on the CAU campus"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withMessage message: Message, args: String) {
		do {
			try UnivISQuery(scheme: univISCAUScheme, host: univISCAUHost, path: univISCAUPath, search: .rooms, params: [
				.name: args
			]).start { response in
				switch response {
					case let .ok(output):
						// Successfully received and parsed UnivIS query output
						guard let room = (output.childs.first { $0 is UnivISRoom }.map { $0 as! UnivISRoom }) else {
							message.channel.send("No room was found!")
							return
						}
						message.channel.send(room.address ?? "Room has no address")
						// message.channel.send([
						// 	DiscordMessageKey.file: MapQuestStaticMap(
						// 		latitude: 0,
						// 		longitude: 0
						// 	).url
						// ])
					case let .error(error):
						print(error)
						message.channel.send("An error occurred while querying. Check the log for more information.")
				}
			}
		} catch {
			print(error)
			message.channel.send("An error occurred. Check the log for more information.")
		}
	}
}
