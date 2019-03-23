import Foundation
import SwiftDiscord

func register(commandsFor handler: CommandHandler) {
	handler["ping"] = PingCommand()
	handler["vertical"] = VerticalCommand()
	handler["bf"] = BFCommand()
	handler["bfencode"] = BFEncodeCommand()
	handler["echo"] = EchoCommand()
	handler["campus"] = CampusCommand()
	handler["type"] = TriggerTypingCommand()
	handler["mdb"] = MDBCommand()
	handler["timetable"] = TimeTableCommand()
	handler["univis"] = UnivISCommand()
	handler["reddit"] = RedditCommand()
	handler["grant"] = GrantPermissionCommand(permissionManager: handler.permissionManager)
	handler["revoke"] = RevokePermissionCommand(permissionManager: handler.permissionManager)
	handler["permissions"] = ShowPermissionsCommand(permissionManager: handler.permissionManager)
	handler["for"] = ForCommand()
	handler["help"] = ClosureCommand(description: "Helps", level: .basic) { [unowned handler] message, _ in
		let helpText = Dictionary(grouping: handler.registry.filter { !$0.value.hidden }, by: { $0.value.requiredPermissionLevel })
			.filter { handler.permissionManager[message.author].rawValue >= $0.key.rawValue }
			.sorted { $0.key.rawValue < $1.key.rawValue }
			.map { group in ":star: \(group.key):\n```\n\(group.value.map { "\($0.key): \($0.value.description)" }.joined(separator: "\n"))\n```" }
			.joined(separator: "\n")
		message.channel?.send(helpText)
	}
}

func main() throws {
	// 'discordToken' should be declared in 'authkeys.swift'
	let handler = try CommandHandler(withPrefix: "%")
	let client = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(discordToken)"), delegate: handler, configuration: [.log(.info)])
	
	register(commandsFor: handler)
	
	print("Connecting client")
	client.connect()
	RunLoop.current.run()
}

try main()
