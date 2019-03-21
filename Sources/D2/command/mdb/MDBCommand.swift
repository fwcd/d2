import SwiftDiscord

class MDBCommand: Command {
	let description = "Queries the Computer Science module database of the CAU"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withMessage message: DiscordMessage, args: String) {
		do {
			let query: MDBQuery
			
			if args.isEmpty {
				query = try MDBQuery()
			} else {
				query = try MDBQuery(moduleCode: args)
			}
			
			query.start { response in
				guard case let .ok(output) = response else {
					message.channel?.send("An error occurred while querying.")
					return
				}
				message.channel?.send(String(describing: output))
			}
		} catch {
			print(error)
			message.channel?.send("An error occurred. Check the log for more information.")
		}
	}
}
