import Sword

class PingCommand: Command {
	func invoke(withMessage message: Message, args: String) {
		message.channel.send("Pong!")
	}
}
