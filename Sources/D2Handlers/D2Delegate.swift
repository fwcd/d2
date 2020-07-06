import D2MessageIO
import Foundation
import Logging
import D2Utils
import D2Commands
import D2Permissions

fileprivate let log = Logger(label: "D2Handlers.D2Delegate")

/** A client delegate that dispatches commands. */
public class D2Delegate: MessageDelegate {
	private let commandPrefix: String
	private let initialPresence: String?
	private let messageDB: MessageDatabase
	private let partyGameDB: PartyGameDatabase
	private let registry: CommandRegistry
	private let eventListenerBus: EventListenerBus
	private let subscriptionManager: SubscriptionManager

	private var messageRewriters: [MessageRewriter]
	private var messageHandlers: [MessageHandler]
	
	public init(withPrefix commandPrefix: String, initialPresence: String? = nil) throws {
		self.commandPrefix = commandPrefix
		self.initialPresence = initialPresence
		
		registry = CommandRegistry()
		messageDB = try MessageDatabase()
		partyGameDB = try PartyGameDatabase()
		eventListenerBus = EventListenerBus()
		subscriptionManager = SubscriptionManager(registry: registry)
		let spamConfiguration = AutoSerializing<SpamConfiguration>(wrappedValue: .init(), filePath: "local/spamConfig.json")
		let permissionManager = PermissionManager()
		let inventoryManager = InventoryManager()

		messageRewriters = [
			MentionSomeoneRewriter()
		]
		messageHandlers = [
			SpamHandler(config: spamConfiguration),
			CommandHandler(commandPrefix: commandPrefix, registry: registry, permissionManager: permissionManager, subscriptionManager: subscriptionManager),
			SubscriptionHandler(commandPrefix: commandPrefix, registry: registry, manager: subscriptionManager),
			MentionD2Handler(conversator: FollowUpConversator(messageDB: messageDB)),
			MentionSomeoneHandler(),
			MessageDatabaseHandler(messageDB: messageDB) // Below other handlers so as to not pick up on commands
		]

		registry["ping"] = PingCommand()
		registry["vertical"] = VerticalCommand()
		registry["bf"] = BFCommand()
		registry["bfencode"] = BFEncodeCommand()
		registry["bftoc"] = BFToCCommand()
		registry["echo"] = EchoCommand()
		registry["timer"] = TimerCommand()
		registry["say"] = SayCommand()
		registry["campus"] = CampusCommand()
		registry["type"] = TriggerTypingCommand()
		registry["weather"] = WeatherCommand()
		registry["webcam"] = WebcamCommand()
		registry["mdb"] = MDBCommand()
		registry["timetable"] = TimeTableCommand()
		registry["univis"] = UnivISCommand()
		registry["mensa"] = MensaCommand()
		registry["spieleabend"] = InfoMessageCommand(text: "This command has been migrated to `\(commandPrefix)countdown`")
		registry["countdown"] = CountdownCommand(goals: ["Spieleabend": SpieleabendGoal()])
		registry["reddit"] = RedditCommand()
		registry["grant"] = GrantPermissionCommand(permissionManager: permissionManager)
		registry["revoke"] = RevokePermissionCommand(permissionManager: permissionManager)
		registry["simulate"] = SimulatePermissionCommand(permissionManager: permissionManager)
		registry["spammerrole"] = SpammerRoleCommand(spamConfiguration: spamConfiguration)
		registry["permissions"] = ShowPermissionsCommand(permissionManager: permissionManager)
		registry["user"] = UserCommand()
		registry["clear"] = ClearCommand()
		registry["logs"] = LogsCommand()
		registry["for"] = ForCommand()
		registry["void"] = VoidCommand()
		registry["do"] = DoCommand()
		registry["quit"] = QuitCommand()
		registry["grep"] = GrepCommand()
		registry["author"] = AuthorCommand()
		registry["addeventlistener", aka: ["on"]] = AddEventListenerCommand(eventListenerBus: eventListenerBus)
		registry["removeeventlistener", aka: ["off"]] = RemoveEventListenerCommand(eventListenerBus: eventListenerBus)
		registry["last"] = LastMessageCommand()
		registry["+"] = BinaryOperationCommand<Double>(name: "addition", operation: +)
		registry["-"] = BinaryOperationCommand<Double>(name: "subtraction", operation: -)
		registry["*"] = BinaryOperationCommand<Double>(name: "multiplication", operation: *)
		registry["/"] = BinaryOperationCommand<Double>(name: "division", operation: /)
		registry["%"] = BinaryOperationCommand<Int>(name: "remainder", operation: %)
		registry["rpn"] = EvaluateExpressionCommand(parser: RPNExpressionParser(), name: "Reverse Polish Notation")
		registry["math"] = EvaluateExpressionCommand(parser: InfixExpressionParser(), name: "Infix Notation")
		registry["matmul"] = MatrixMultiplicationCommand()
		registry["identitymat", aka: ["idmat", "onemat"]] = IdentityMatrixCommand()
		registry["zeromat"] = ZeroMatrixCommand()
		registry["dot"] = DotProductCommand()
		registry["determinant", aka: ["det"]] = DeterminantCommand()
		registry["inverse", aka: ["inversemat", "invmat", "invert"]] = InverseMatrixCommand()
		registry["rowecholonform", aka: ["rowecholon", "gausseliminate"]] = RowEcholonFormCommand()
		registry["orthogonalize", aka: ["orthogonal", "ortho"]] = OrthogonalizeCommand()
		registry["transpose"] = TransposeCommand()
		registry["solvelinearsystem", aka: ["solvelinear"]] = SolveLinearSystemCommand()
		registry["maxima"] = MaximaCommand()
		registry["integral"] = IntegralCalculatorCommand()
		registry["translate"] = TranslateCommand()
		registry["portal"] = PortalCommand()
		registry["mcping"] = MinecraftServerPingCommand()
		registry["mcmods"] = MinecraftServerModsCommand()
		registry["mcmod"] = MinecraftModSearchCommand()
        registry["mcdynchat"] = MinecraftDynmapChatCommand()
		registry["mcdynmap"] = MinecraftDynmapCommand()
		registry["mcwiki"] = MinecraftWikiCommand()
		registry["mcstronghold"] = MinecraftStrongholdFinderCommand()
		registry["ftbpacks"] = FTBModpacksCommand()
		registry["gmodping"] = GModServerPingCommand()
		registry["wolframalpha"] = WolframAlphaCommand()
		registry["stackoverflow"] = StackOverflowCommand()
		registry["wikipedia"] = WikipediaCommand()
		registry["dblp"] = DBLPCommand()
		registry["gitlab"] = GitLabCommand()
		registry["perceptron"] = PerceptronCommand()
		registry["tictactoe"] = GameCommand<TicTacToeGame>()
		registry["uno"] = GameCommand<UnoGame>()
		registry["sourcefile"] = SourceFileCommand()
		registry["urbandict"] = UrbanDictionaryCommand()
		registry["chess"] = GameCommand<ChessGame>()
		registry["cyclethrough"] = CycleThroughCommand()
		registry["demoimage"] = DemoImageCommand()
		registry["demogif"] = DemoGifCommand()
		registry["color"] = ColorCommand()
		registry["mandelbrot"] = MandelbrotCommand()
		registry["invert"] = InvertCommand()
		registry["spin"] = AnimateCommand<SpinAnimation>(description: "Rotates an image")
		registry["twirl"] = AnimateCommand<TransformAnimation<TwirlTransform>>(description: "Applies a twirl distortion effect")
		registry["bump"] = AnimateCommand<TransformAnimation<RadialTransform<BumpDistortion>>>(description: "Applies a bump distortion effect")
		registry["pinch"] = AnimateCommand<TransformAnimation<RadialTransform<PinchDistortion>>>(description: "Applies an inverse bump distortion effect")
		registry["warp"] = AnimateCommand<TransformAnimation<RadialTransform<WarpDistortion>>>(description: "Applies a warp distortion effect")
		registry["squiggle"] = AnimateCommand<TransformAnimation<SquiggleTransform>>(description: "Applies a 'squiggling' distortion effect")
		registry["pingpong"] = PingPongCommand()
		registry["reverse"] = ReverseCommand()
		registry["togif"] = ToGifCommand()
		registry["avatar"] = AvatarCommand()
		registry["qr"] = QRCommand()
		registry["latex"] = LatexCommand()
		registry["autolatex"] = AutoLatexCommand()
		registry["hoogle"] = HoogleCommand()
		registry["haskell"] = HaskellCommand()
		registry["pointfree"] = PointfreeCommand()
		registry["pointful"] = PointfulCommand()
		registry["prolog"] = PrologCommand()
		registry["piglatin"] = PigLatinCommand()
		registry["rickroll"] = RickrollCommand()
		registry["micdrop"] = MicdropCommand()
		registry["pokemon"] = PokemonCommand(inventoryManager: inventoryManager)
		registry["pokedex"] = PokedexCommand()
		registry["pokequiz"] = PokeQuizCommand()
		registry["iambored"] = IAmBoredCommand()
		registry["discordinder"] = DiscordinderCommand(inventoryManager: inventoryManager)
		registry["chucknorrisjoke", aka: ["cnj"]] = ChuckNorrisJokeCommand()
		registry["wouldyourather", aka: ["wyr"]] = WouldYouRatherCommand(partyGameDB: partyGameDB)
		registry["partygamedb"] = PartyGameDatabaseCommand(partyGameDB: partyGameDB)
		registry["advice"] = AdviceCommand()
		registry["magic8ball", aka: ["7ball", "8ball", "9ball"]] = Magic8BallCommand()
		registry["random"] = RandomCommand(permissionManager: permissionManager)
		registry["commandoftheday", aka: ["cotd"]] = CommandOfTheDayCommand(commandPrefix: commandPrefix)
		registry["commandcount", aka: ["cmdcount"]] = CommandCountCommand()
		registry["inventory"] = InventoryCommand(inventoryManager: inventoryManager)
		registry["trade"] = TradeCommand(inventoryManager: inventoryManager)
		registry["cookie"] = CookieCommand(inventoryManager: inventoryManager)
		registry["messagedb"] = MessageDatabaseCommand(messageDB: messageDB)
		registry["messagedbquery"] = MessageDatabaseQueryCommand(messageDB: messageDB)
		registry["shell"] = ShellCommand()
		registry["upload"] = UploadCommand()
		registry["markov"] = MarkovCommand(messageDB: messageDB)
		registry["conversate"] = ConversateCommand(conversator: FollowUpConversator(messageDB: messageDB))
		registry["emoji"] = EmojiCommand()
		registry["uwu", aka: ["owo"]] = UwUCommand()
		registry["karma"] = KarmaCommand(messageDB: messageDB)
		registry["watch"] = WatchCommand()
		registry["poll"] = PollCommand()
		registry["concat"] = ConcatCommand()
		registry["revconcat"] = ReverseConcatCommand()
		registry["rev"] = ReverseInputCommand()
		registry["identity", aka: ["id"]] = IdentityCommand()
		registry["presence"] = PresenceCommand()
		registry["xkcd"] = XkcdCommand()
		registry["coinflip", aka: ["coin"]] = CoinFlipCommand()
		registry["diceroll", aka: ["dice"]] = DiceRollCommand(1...6)
		registry["directmessage", aka: ["dm"]] = DirectMessageCommand()
		registry["channelmessage", aka: ["m"]] = ChannelMessageCommand()
		registry["tofile"] = ToFileCommand()
		registry["cleanmentions"] = CleanMentionsCommand()
		registry["chord"] = FretboardChordCommand()
		registry["web"] = WebCommand()
		registry["get"] = HTTPRequestCommand(method: "GET")
		registry["post"] = HTTPRequestCommand(method: "POST")
		registry["put"] = HTTPRequestCommand(method: "PUT")
		registry["patch"] = HTTPRequestCommand(method: "PATCH")
		registry["delete"] = HTTPRequestCommand(method: "DELETE")
		registry["stats"] = StatsCommand()
		registry["whatsup"] = WhatsUpCommand()
		registry["songcharts"] = SongChartsCommand()
		registry["sortby"] = SortByCommand()
		registry["addscript"] = AddD2ScriptCommand()
		registry["discordstatus"] = DiscordStatusCommand()
		registry["ioplatform"] = IOPlatformCommand()
		registry["sysinfo"] = SysInfoCommand()
		registry["help", aka: ["h"]] = HelpCommand(commandPrefix: commandPrefix, permissionManager: permissionManager)
	}

	public func on(connect connected: Bool, client: MessageClient) {
		client.setPresence(PresenceUpdate(game: Presence.Activity(name: initialPresence ?? "\(commandPrefix)help", type: .listening)))
		eventListenerBus.fire(event: .connect, with: .none)

		do {
			try messageDB.setupTables(client: client)
		} catch {
			log.warning("Could not setup message database: \(error)")
		}

		do {
			try partyGameDB.setupTables()
		} catch {
			log.warning("Could not setup party game database: \(error)")
		}
	}
	
	public func on(receivePresenceUpdate presence: Presence, client: MessageClient) {
		for (_, entry) in registry {
			if case let .command(command) = entry {
				command.onReceivedUpdated(presence: presence)
			}
		}
		eventListenerBus.fire(event: .receivePresenceUpdate, with: presence.game.map { RichValue.text($0.name) } ?? .none) // TODO: Pass full presence?
	}

	public func on(createGuild guild: Guild, client: MessageClient) {
		do {
			try messageDB.insert(guild: guild)
		} catch {
			log.warning("Could not insert guild into message database: \(error)")
		}
		eventListenerBus.fire(event: .createGuild, with: .none) // TODO: Provide guild ID?
	}
	
	public func on(createMessage message: Message, client: MessageClient) {
		var m = message
		
		for rewriter in messageRewriters {
			if let rewrite = rewriter.rewrite(message: m, from: client) {
				m = rewrite
			}
		}

		for (i, _) in messageHandlers.enumerated() {
			if messageHandlers[i].handleRaw(message: message, from: client) {
				return
			}
			if messageHandlers[i].handle(message: m, from: client) {
				return
			}
		}

		// Only fire on unhandled messages
		if m.author?.id != client.me?.id {
			MessageParser().parse(message: m) {
				self.eventListenerBus.fire(event: .createMessage, with: $0, context: CommandContext(
					client: client,
					registry: self.registry,
					message: m,
					commandPrefix: self.commandPrefix,
					subscriptions: .init()
				))
			}
		}
	}

	public func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {
		guard
			let guild = client.guildForChannel(channelId),
			let member = guild.members[userId] else { return }
		// TODO: Query the actual message that the user reacted to here
		let message = Message(content: "Dummy", channelId: channelId, id: messageId)
		let user = member.user
		subscriptionManager.notifySubscriptions(on: channelId, isBot: user.bot) {
			let context = CommandContext(
				client: client,
				registry: registry,
				message: message,
				commandPrefix: commandPrefix,
				subscriptions: $1
			)
			registry[$0]?.onSubscriptionReaction(emoji: reaction, by: user, output: MessageIOOutput(context: context), context: context)
		}
	}

	public func on(updateMessage message: Message, client: MessageClient) {
		MessageParser().parse(message: message) {
			self.eventListenerBus.fire(event: .updateMessage, with: $0, context: CommandContext(
				client: client,
				registry: self.registry,
				message: message,
				commandPrefix: self.commandPrefix,
				subscriptions: .init()
			))
		}
	}

	public func on(disconnectWithReason reason: String, client: MessageClient) {
		eventListenerBus.fire(event: .disconnectWithReason, with: .text(reason))
	}

	public func on(createChannel channelId: ChannelID, client: MessageClient) {
		eventListenerBus.fire(event: .createChannel, with: .none) // TODO: Pass channel ID?
	}

	public func on(deleteChannel channelId: ChannelID, client: MessageClient) {
		eventListenerBus.fire(event: .deleteChannel, with: .none) // TODO: Pass channel ID?
	}

	public func on(updateChannel channelId: ChannelID, client: MessageClient) {
		eventListenerBus.fire(event: .updateChannel, with: .none) // TODO: Pass channel ID?
	}

	public func on(deleteGuild guild: Guild, client: MessageClient) {
		eventListenerBus.fire(event: .deleteGuild, with: .none) // TODO: Pass guild ID?
	}

	public func on(updateGuild guild: Guild, client: MessageClient) {
		eventListenerBus.fire(event: .updateGuild, with: .none) // TODO: Pass guild ID?
	}

	public func on(addGuildMember member: Guild.Member, client: MessageClient) {
		eventListenerBus.fire(event: .addGuildMember, with: .mentions([member.user]))
	}

	public func on(removeGuildMember member: Guild.Member, client: MessageClient) {
		eventListenerBus.fire(event: .removeGuildMember, with: .mentions([member.user]))
	}

	public func on(updateGuildMember member: Guild.Member, client: MessageClient) {
		eventListenerBus.fire(event: .updateGuildMember, with: .mentions([member.user]))
	}

	public func on(createRole role: Role, on guild: Guild, client: MessageClient) {
		eventListenerBus.fire(event: .createRole, with: .none) // TODO: Pass role ID/role mention?
	}

	public func on(deleteRole role: Role, from guild: Guild, client: MessageClient) {
		eventListenerBus.fire(event: .deleteRole, with: .none) // TODO: Pass role ID/role mention?
	}

	public func on(updateRole role: Role, on guild: Guild, client: MessageClient) {
		eventListenerBus.fire(event: .updateRole, with: .none) // TODO: Pass role ID/role mention?
	}

	public func on(receiveReady data: [String: Any], client: MessageClient) {
		eventListenerBus.fire(event: .receiveReady, with: .none) // TODO: Pass data?
	}

	public func on(receiveVoiceStateUpdate state: VoiceState, client: MessageClient) {
		eventListenerBus.fire(event: .receiveVoiceStateUpdate, with: .none) // TODO: Pass state?
	}

	public func on(handleGuildMemberChunk chunk: LazyDictionary<UserID, Guild.Member>, for guild: Guild, client: MessageClient) {
		eventListenerBus.fire(event: .handleGuildMemberChunk, with: .none) // TODO: Pass state?
	}

	public func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: MessageClient) {
		eventListenerBus.fire(event: .updateEmojis, with: .none) // TODO: Pass emojis, possibly by creating a RichValue.emoji variant
	}
}
