import Sword
import Foundation

class CommandHandler: ClientHandler {
	private let commandPattern: Regex
	private(set) var commands = [String : Command]()
	
	init(withPrefix msgPrefix: String) throws {
		let escapedPrefix = NSRegularExpression.escapedPattern(for: msgPrefix)
		// The first group matches the command name,
		// the second matches the arguments (the rest of the message content)
		commandPattern = try Regex(from: "\(escapedPrefix)(\\w+)(?:\\s+([\\s\\S]*))?")
	}
	
	func on(createMessage message: Message) {
		if let groups = commandPattern.firstGroups(in: message.content) {
			print("Got command \(groups)")
			let name = groups[1]
			let args = groups[2]
			
			if let command = commands[name] {
				print("Invoking '\(name)'")
				command.invoke(withMessage: message, args: args)
			} else {
				print("Did not recognize command '\(name)'")
				message.channel.send("Sorry, I do not know the command `\(name)`.")
			}
		}
	}
	
	subscript(name: String) -> Command? {
		get { return commands[name] }
		set(newValue) { commands[name] = newValue }
	}
}
