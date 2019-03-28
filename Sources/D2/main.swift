import Foundation
import SwiftDiscord

/** Registers all available commands. */
func register(commandsFor handler: CommandHandler) {
	handler["ping"] = PingCommand()
	handler["vertical"] = VerticalCommand()
	handler["bf"] = BFCommand()
	handler["bfencode"] = BFEncodeCommand()
	handler["bftoc"] = BFToCCommand()
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
	handler["void"] = VoidCommand()
	handler["grep"] = GrepCommand()
	handler["last"] = LastMessageCommand()
	handler["+"] = BinaryOperationCommand<Double>(name: "addition", operation: +)
	handler["-"] = BinaryOperationCommand<Double>(name: "subtraction", operation: -)
	handler["*"] = BinaryOperationCommand<Double>(name: "multiplication", operation: *)
	handler["/"] = BinaryOperationCommand<Double>(name: "division", operation: /)
	handler["%"] = BinaryOperationCommand<Int>(name: "remainder", operation: %)
	handler["rpn"] = RPNCommand()
	handler["tictactoe"] = TicTacToeCommand()
	handler["cyclethrough"] = CycleThroughCommand()
	handler["draw"] = DrawCommand()
	handler["help"] = ClosureCommand(description: "Helps", level: .basic) { [unowned handler] _, output, context, _ in
		let helpText = Dictionary(grouping: handler.registry.filter { !$0.value.hidden }, by: { $0.value.requiredPermissionLevel })
			.filter { handler.permissionManager[context.author].rawValue >= $0.key.rawValue }
			.sorted { $0.key.rawValue < $1.key.rawValue }
			.map { group in ":star: \(group.key):\n```\n\(group.value.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value.description)" }.joined(separator: "\n"))\n```" }
			.joined(separator: "\n")
		output.append(helpText)
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
