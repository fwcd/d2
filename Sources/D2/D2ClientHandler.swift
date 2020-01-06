import SwiftDiscord
import Foundation
import D2Utils
import D2Commands
import D2Permissions

/** A client delegate that dispatches commands. */
class D2ClientHandler: DiscordClientDelegate {
	private let commandPrefix: String
	private let initialPresence: String?
	private var messageHandlers: [MessageHandler]
	
	init(withPrefix commandPrefix: String, initialPresence: String? = nil) throws {
		self.commandPrefix = commandPrefix
		self.initialPresence = initialPresence
		
		let registry = CommandRegistry()
		let spamConfiguration = try AutoSerializing<SpamConfiguration>(filePath: "local/spamConfig.json")
		let permissionManager = PermissionManager()
		let subscriptionManager = SubscriptionManager()

		messageHandlers = [
			SpamHandler(config: spamConfiguration),
			CommandHandler(commandPrefix: commandPrefix, registry: registry, permissionManager: permissionManager, subscriptionManager: subscriptionManager),
			SubscriptionHandler(registry: registry, manager: subscriptionManager)
		]

		registry["ping"] = PingCommand()
		registry["vertical"] = VerticalCommand()
		registry["bf"] = BFCommand()
		registry["bfencode"] = BFEncodeCommand()
		registry["bftoc"] = BFToCCommand()
		registry["echo"] = EchoCommand()
		registry["campus"] = CampusCommand()
		registry["type"] = TriggerTypingCommand()
		registry["mdb"] = MDBCommand()
		registry["timetable"] = TimeTableCommand()
		registry["univis"] = UnivISCommand()
		registry["mensa"] = MensaCommand()
		registry["spieleabend"] = InfoMessageCommand(text: "This command has been migrated to `\(commandPrefix)countdown`")
		registry["countdown"] = CountdownCommand(goals: ["Spieleabend": SpieleabendGoal()])
		registry["reddit"] = RedditCommand()
		registry["grant"] = GrantPermissionCommand(permissionManager: permissionManager)
		registry["revoke"] = RevokePermissionCommand(permissionManager: permissionManager)
		registry["spammerrole"] = SpammerRoleCommand(spamConfiguration: spamConfiguration)
		registry["permissions"] = ShowPermissionsCommand(permissionManager: permissionManager)
		registry["logs"] = LogsCommand()
		registry["for"] = ForCommand()
		registry["void"] = VoidCommand()
		registry["quit"] = QuitCommand()
		registry["grep"] = GrepCommand()
		registry["last"] = LastMessageCommand()
		registry["+"] = BinaryOperationCommand<Double>(name: "addition", operation: +)
		registry["-"] = BinaryOperationCommand<Double>(name: "subtraction", operation: -)
		registry["*"] = BinaryOperationCommand<Double>(name: "multiplication", operation: *)
		registry["/"] = BinaryOperationCommand<Double>(name: "division", operation: /)
		registry["%"] = BinaryOperationCommand<Int>(name: "remainder", operation: %)
		registry["rpn"] = EvaluateExpressionCommand(parser: RPNExpressionParser(), name: "Reverse Polish Notation")
		registry["math"] = EvaluateExpressionCommand(parser: InfixExpressionParser(), name: "Infix Notation")
		registry["maxima"] = MaximaCommand()
		registry["mcping"] = MinecraftServerPingCommand()
		registry["wolframalpha"] = WolframAlphaCommand()
		registry["stackoverflow"] = StackOverflowCommand()
		registry["gitlab"] = GitLabCommand()
		registry["perceptron"] = PerceptronCommand()
		registry["tictactoe"] = GameCommand<TicTacToeGame>()
		registry["uno"] = GameCommand<UnoGame>()
		registry["sourcefile"] = SourceFileCommand()
		registry["chess"] = GameCommand<ChessGame>()
		registry["cyclethrough"] = CycleThroughCommand()
		registry["demoimage"] = DemoImageCommand()
		registry["demogif"] = DemoGifCommand()
		registry["mandelbrot"] = MandelbrotCommand()
		registry["invert"] = InvertCommand()
		registry["spin"] = SpinCommand()
		registry["togif"] = ToGifCommand()
		registry["avatar"] = AvatarCommand()
		registry["latex"] = LatexCommand()
		registry["autolatex"] = AutoLatexCommand()
		registry["hoogle"] = HoogleCommand()
		registry["haskell"] = HaskellCommand()
		registry["pointfree"] = PointfreeCommand()
		registry["pointful"] = PointfulCommand()
		registry["piglatin"] = PigLatinCommand()
		registry["markov"] = MarkovCommand()
		registry["watch"] = WatchCommand()
		registry["poll"] = PollCommand()
		registry["concat"] = ConcatCommand()
		registry["presence"] = PresenceCommand()
		registry["xkcd"] = XkcdCommand()
		registry["dm"] = DirectMessageCommand()
		registry["tofile"] = ToFileCommand()
		registry["chord"] = GuitarChordCommand()
		registry["web"] = WebCommand()
		registry["stats"] = StatsCommand()
		registry["sortby"] = SortByCommand()
		registry["addscript"] = AddD2ScriptCommand()
		registry["help"] = HelpCommand(commandPrefix: commandPrefix, permissionManager: permissionManager)
	}

	func client(_ client: DiscordClient, didConnect connected: Bool) {
		client.setPresence(DiscordPresenceUpdate(game: DiscordActivity(name: initialPresence ?? "\(commandPrefix)help", type: .listening)))
	}
	
	func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
		for (i, _) in messageHandlers.enumerated() {
			if messageHandlers[i].handle(message: message, from: client) {
				break
			}
		}
	}
}
