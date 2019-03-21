import Sword

class PingCommand: Command {
	let description = "Replies with 'Pong!'"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withMessage message: Message, args: String) {
		message.channel.send("Pong!")
	}
}
