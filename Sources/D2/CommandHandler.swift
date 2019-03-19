import Sword
import Foundation

class CommandHandler: ClientHandler {
	private let commandPattern: Regex
	private var commands = [String : Command]()
	
	init(withPrefix msgPrefix: String) throws {
		let escapedPrefix = NSRegularExpression.escapedPattern(for: msgPrefix)
		// The first group matches the command name,
		// the second matches the arguments (the rest of the message content)
		commandPattern = try Regex(from: "\(escapedPrefix)(\\w+)(?:\\s+(.*))?")
	}
	
	func on(createMessage message: Message) {
		if let groups = commandPattern.firstGroups(in: message.content) {
			let name = groups[1]
			let args = groups[2]
			
			if let command = commands[name] {
				command.invoke(withMessage: message, args: args)
			}
		}
	}
	
	func add(withName name: String, command: Command) {
		commands[name] = command
	}
}
