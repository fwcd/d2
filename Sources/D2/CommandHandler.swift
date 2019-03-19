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
		let matches = commandPattern.matches(in: message.content)
		
		if !matches.isEmpty {
			print("\(matches)")
			let commandName = matches[0]
			let commandArgs = matches[1]
			if let command = commands[commandName] {
				command.invoke(withMessage: message, args: commandArgs)
			}
		}
	}
	
	func add(withName name: String, command: Command) {
		commands[name] = command
	}
}
