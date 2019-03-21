import SwiftDiscord

class MDBCommand: Command {
	let description = "Queries the Computer Science module database of the CAU"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withMessage message: DiscordMessage, args: String) {
		
	}
}
