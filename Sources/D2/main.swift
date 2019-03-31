import Foundation
import SwiftDiscord
import D2Commands
import D2Utils

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
	handler["tictactoe"] = TwoPlayerGameCommand<TicTacToeState>(withName: "tic tac toe")
	handler["cyclethrough"] = CycleThroughCommand()
	handler["demoimage"] = DemoImageCommand()
	handler["dm"] = DirectMessageCommand()
	handler["help"] = HelpCommand(permissionManager: handler.permissionManager)
}

func main() throws {
	let handler = try CommandHandler(withPrefix: "%")
	let token = try DiskJsonSerializer().readJson(as: Token.self, fromFile: "local/discordToken.json").token
	let client = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(token)"), delegate: handler, configuration: [.log(.info)])
	
	register(commandsFor: handler)
	
	print("Connecting client")
	client.connect()
	RunLoop.current.run()
}

try main()
