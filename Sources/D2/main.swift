import Foundation
import Sword

func main() throws {
	try UnivISQuery(scheme: "http", host: "univis.uni-kiel.de", path: "/prg", search: .lectures, params: [
		.name: "Algorithmen"
	]).start {
		switch $0 {
			case let .ok(value): print(value)
			case let .error(error): print(error)
		}
	}
	
	// 'discordToken' should be declared in 'authkeys.swift'
	let client = Sword(token: discordToken)
	let handler = try CommandHandler(withPrefix: "%")
	
	handler["ping"] = PingCommand()
	handler["vertical"] = VerticalCommand()
	handler["bf"] = BFCommand()
	handler["bfencode"] = BFEncodeCommand()
	handler["echo"] = EchoCommand()
	handler["help"] = ClosureCommand(description: "Helps", level: .basic) { [unowned handler] message, _ in
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
