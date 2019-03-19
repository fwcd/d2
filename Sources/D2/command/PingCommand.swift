import Sword

class PingCommand: Command {
	let description = "Replies with 'Pong!'"
	
	func invoke(withMessage message: Message, args: String) {
		message.channel.send("Pong!")
	}
}
