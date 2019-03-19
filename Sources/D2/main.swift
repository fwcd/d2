import Foundation
import Sword

func main() throws {
	// 'discordToken' should be declared in 'authkeys.swift'
	let client = Sword(token: discordToken)
	let handler = try CommandHandler(withPrefix: "%")
	
	handler["ping"] = PingCommand()
	handler["vertical"] = VerticalCommand()
	handler["help"] = ClosureCommand(description: "Helps") { [unowned handler] message, _ in
		let helpText = handler.commands
			.map { "\($0.key): \($0.value.description)" }
			.reduce("") { "\($0)\n\($1)" }
		message.channel.send("```\n\(helpText)\n```")
	}
	
	client.on(.messageCreate) { handler.on(createMessage: $0 as! Message) }
	
	print("Connecting client")
	client.connect()
}

try main()
