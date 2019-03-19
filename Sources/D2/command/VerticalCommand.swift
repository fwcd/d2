import Sword

class VerticalCommand: Command {
	let description = "Reads horizontally, prints vertically"
	
	func invoke(withMessage message: Message, args: String) {
		message.channel.send(args.reduce("") { "\($0)\n\($1)" })
	}
}
