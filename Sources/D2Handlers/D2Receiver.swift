import D2MessageIO
import D2NetAPIs
import Foundation
import Logging
import Utils
import D2Commands
import D2Permissions

import class NIO.MultiThreadedEventLoopGroup
import protocol NIO.EventLoopGroup

fileprivate let log = Logger(label: "D2Handlers.D2Receiver")

/// D2's main event handler.
public class D2Receiver: Receiver {
    private let commandPrefix: String
    private let hostInfo: HostInfo
    private let initialPresence: String?
    private let useMIOCommands: Bool
    private let mioCommandGuildId: GuildID?
    private let eventLoopGroup: any EventLoopGroup

    private let messageDB: MessageDatabase
    private let partyGameDB: PartyGameDatabase
    private let registry: CommandRegistry
    private let eventListenerBus: EventListenerBus
    private let cronManager: CronManager
    private let subscriptionManager: SubscriptionManager
    private let permissionManager: PermissionManager

    private var messageRewriters: [any MessageRewriter]
    private var messageHandlers: [any MessageHandler]
    private var reactionHandlers: [any ReactionHandler]
    private var presenceHandlers: [any PresenceHandler]
    private var channelHandlers: [any ChannelHandler]
    private var interactionHandlers: [any InteractionHandler]

    public init(
        withPrefix commandPrefix: String,
        hostInfo: HostInfo,
        initialPresence: String? = nil,
        useMIOCommands: Bool = false,
        mioCommandGuildId: GuildID? = nil,
        logBuffer: LogBuffer,
        eventLoopGroup: any EventLoopGroup,
        sink: any Sink
    ) throws {
        self.commandPrefix = commandPrefix
        self.hostInfo = hostInfo
        self.initialPresence = initialPresence
        self.useMIOCommands = useMIOCommands
        self.mioCommandGuildId = mioCommandGuildId
        self.eventLoopGroup = eventLoopGroup

        registry = CommandRegistry()
        messageDB = try MessageDatabase()
        partyGameDB = try PartyGameDatabase()
        eventListenerBus = EventListenerBus()
        cronManager = CronManager(registry: registry, sink: sink, commandPrefix: commandPrefix, hostInfo: hostInfo, eventLoopGroup: eventLoopGroup)
        subscriptionManager = SubscriptionManager(registry: registry)
        permissionManager = PermissionManager()
        let inventoryManager = InventoryManager()

        @Synchronized @Box var mostRecentPipeRunner: (any AsyncRunnable, PermissionLevel)? = nil
        @AutoSerializing(filePath: "local/spamConfig.json") var spamConfiguration = SpamConfiguration()
        @AutoSerializing(filePath: "local/streamerRoleConfig.json") var streamerRoleConfiguration = StreamerRoleConfiguration()
        @AutoSerializing(filePath: "local/messagePreviewsConfig.json") var messagePreviewsConfiguration = MessagePreviewsConfiguration()
        @AutoSerializing(filePath: "local/haikuConfig.json") var haikuConfiguration = HaikuConfiguration()
        @AutoSerializing(filePath: "local/threadConfig.json") var threadConfiguration = ThreadConfiguration()
        @AutoSerializing(filePath: "local/roleReactionsConfig.json") var roleReactionsConfiguration = RoleReactionsConfiguration()
        @AutoSerializing(filePath: "local/triggerReactionConfiguration.json") var triggerReactionConfiguration = TriggerReactionConfiguration()
        @AutoSerializing(filePath: "local/pronounRoleConfig.json") var pronounRoleConfiguration = PronounRoleConfiguration()
        @AutoSerializing(filePath: "local/cityConfig.json") var cityConfiguration = CityConfiguration()

        messageRewriters = [
            MentionSomeoneRewriter()
        ]
        messageHandlers = [
            SpamHandler($config: $spamConfiguration),
            CommandHandler(commandPrefix: commandPrefix, hostInfo: hostInfo, registry: registry, permissionManager: permissionManager, subscriptionManager: subscriptionManager, eventLoopGroup: eventLoopGroup, mostRecentPipeRunner: _mostRecentPipeRunner),
            SubscriptionHandler(commandPrefix: commandPrefix, hostInfo: hostInfo, registry: registry, manager: subscriptionManager, eventLoopGroup: eventLoopGroup),
            MentionD2Handler(conversator: FollowUpConversator(messageDB: messageDB)),
            MentionSomeoneHandler(),
            MessagePreviewHandler($configuration: $messagePreviewsConfiguration),
            TriggerReactionHandler($configuration: $triggerReactionConfiguration, $cityConfiguration: $cityConfiguration),
            CountToNHandler(),
            UniversalSummoningHandler(hostInfo: hostInfo),
            HaikuHandler($configuration: $haikuConfiguration, inventoryManager: inventoryManager),
            LuckyNumberHandler(luckyNumbers: [69, 42, 1337], acceptPowerOfTenMultiples: true, minimumNumberCount: 2),
            FactorialHandler(),
            MessageDatabaseHandler(messageDB: messageDB) // Below other handlers so as to not pick up on commands
        ]
        reactionHandlers = [
            RoleReactionHandler($configuration: $roleReactionsConfiguration),
            SubscriptionReactionHandler(commandPrefix: commandPrefix, registry: registry, manager: subscriptionManager, eventLoopGroup: eventLoopGroup),
            MessageDatabaseReactionHandler(messageDB: messageDB)
        ]
        presenceHandlers = [
            StreamerRoleHandler($streamerRoleConfiguration: $streamerRoleConfiguration)
        ]
        channelHandlers = [
            ThreadKeepaliveHandler($config: $threadConfiguration),
            MessageDatabaseChannelHandler(messageDB: messageDB)
        ]
        interactionHandlers = [
            SubscriptionInteractionHandler(commandPrefix: commandPrefix, hostInfo: hostInfo, registry: registry, manager: subscriptionManager, eventLoopGroup: eventLoopGroup)
        ]

        if useMIOCommands {
            interactionHandlers.append(MIOCommandInteractionHandler(registry: registry, hostInfo: hostInfo, permissionManager: permissionManager, eventLoopGroup: eventLoopGroup))
        }

        registry["ping"] = PingCommand()
        registry["beep"] = PingCommand(response: "Bop")
        registry["instance"] = InstanceCommand()
        registry["vertical"] = VerticalCommand()
        registry["bfinterpret", aka: ["bf"]] = BFInterpretCommand()
        registry["bfencode"] = BFEncodeCommand()
        registry["bftoc"] = BFToCCommand()
        registry["base64encode", aka: ["base64"]] = Base64EncoderCommand()
        registry["base64decode"] = Base64DecoderCommand()
        registry["caesar", aka: ["rot"]] = CaesarCipherCommand()
        registry["echo"] = EchoCommand()
        registry["timer"] = TimerCommand()
        registry["say"] = SayCommand()
        registry["campus"] = CampusCommand()
        registry["type"] = TriggerTypingCommand()
        registry["city"] = CityCommand($config: $cityConfiguration)
        registry["weather"] = WeatherCommand($config: $cityConfiguration)
        registry["lightning", aka: ["l", "zap"]] = LightningCommand()
        registry["sunrisesunset", aka: ["sunrise", "sunset", "twilight", "dawn", "dusk"]] = SunriseSunsetCommand()
        registry["webcam"] = WebcamCommand()
        registry["mdb"] = MDBCommand()
        registry["timetable"] = TimeTableCommand()
        registry["univis"] = UnivISCommand()
        registry["exam", aka: ["exams"]] = ExamCommand()
        registry["mensa"] = MensaCommand()
        registry["yo"] = YoCommand()
        registry["countdown", aka: ["countdowns", "events"]] = CountdownCommand(builtInGoals: ["Christmas Eve": ChristmasEveGoal(), "New Year's Eve": NewYearsEveGoal()])
        registry["reddit", aka: ["r", "sub", "subreddit"]] = RedditCommand(presenter: RedditFeedPresenter())
        registry["redditpost", aka: ["rp"]] = RedditCommand(presenter: RedditPostPresenter())
        registry["grant"] = GrantPermissionCommand(permissionManager: permissionManager)
        registry["revoke"] = RevokePermissionCommand(permissionManager: permissionManager)
        registry["simulate"] = SimulatePermissionCommand(permissionManager: permissionManager)
        registry["spammerrole"] = SpammerRoleCommand($spamConfiguration: $spamConfiguration)
        registry["streamerrole", aka: ["twitchrole"]] = StreamerRoleCommand($streamerRoleConfiguration: $streamerRoleConfiguration)
        registry["messagepreviews"] = MessagePreviewsCommand($configuration: $messagePreviewsConfiguration)
        registry["haikus"] = HaikusCommand($configuration: $haikuConfiguration)
        registry["thread"] = ThreadCommand($config: $threadConfiguration)
        registry["threads"] = ThreadsCommand()
        registry["permissions"] = ShowPermissionsCommand(permissionManager: permissionManager)
        registry["userinfo", aka: ["user"]] = UserInfoCommand()
        registry["clear"] = ClearCommand()
        registry["rolereactions"] = RoleReactionsCommand($configuration: $roleReactionsConfiguration)
        registry["logs"] = LogsCommand(logBuffer: logBuffer)
        registry["embeddescription", aka: ["description"]] = EmbedDescriptionCommand()
        registry["embedfooter", aka: ["footer"]] = EmbedFooterCommand()
        registry["embedfields", aka: ["fields"]] = EmbedFieldsCommand()
        registry["row"] = RowCommand()
        registry["column", aka: ["col"]] = ColumnCommand()
        registry["tabletotext"] = TableToTextCommand()
        registry["tabletondarray", aka: ["tondarray"]] = TableToNDArrayCommand()
        registry["for"] = ForCommand()
        registry["do"] = DoCommand()
        registry["quit"] = QuitCommand()
        registry["blockforever", aka: ["block"]] = BlockForeverCommand()
        registry["removeallmiocommands"] = RemoveAllMIOCommandsCommand()
        registry["grep"] = GrepCommand()
        registry["author"] = AuthorCommand()
        registry["addeventlistener", aka: ["on"]] = AddEventListenerCommand(eventListenerBus: eventListenerBus)
        registry["removeeventlistener", aka: ["off"]] = RemoveEventListenerCommand(eventListenerBus: eventListenerBus)
        registry["addcronschedule", aka: ["cron"]] = AddCronScheduleCommand(cronManager: cronManager)
        registry["removecronschedule", aka: ["uncron", "removecron"]] = RemoveCronScheduleCommand(cronManager: cronManager)
        registry["last"] = LastMessageCommand()
        registry["convert"] = UnitConverterCommand()
        registry["+"] = BinaryOperationCommand<Double>(name: "addition", operation: +)
        registry["-"] = BinaryOperationCommand<Double>(name: "subtraction", operation: -)
        registry["*"] = BinaryOperationCommand<Double>(name: "multiplication", operation: *)
        registry["/"] = BinaryOperationCommand<Double>(name: "division", operation: /)
        registry["%"] = BinaryOperationCommand<Int>(name: "remainder", operation: %)
        registry["rpn"] = EvaluateExpressionCommand(parser: RPNExpressionParser(), name: "Reverse Polish Notation")
        registry["primefactorization", aka: ["factor", "factorize", "factors", "primefactorize"]] = PrimeFactorizationCommand()
        registry["reducefraction", aka: ["reduce"]] = ReduceFractionCommand()
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
        registry["solvequadratic"] = SolveQuadraticEquationCommand()
        registry["shape"] = ShapeCommand()
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
        registry["ftbmodpacks", aka: ["ftbpacks"]] = FTBModpacksCommand()
        registry["epicfreegames", aka: ["epicfree", "freegames"]] = EpicFreeGamesCommand()
        registry["gmodping"] = GModServerPingCommand()
        registry["wolframalpha"] = WolframAlphaCommand()
        registry["stackoverflow"] = StackOverflowCommand()
        registry["wikipedia"] = WikipediaCommand()
        registry["dblp"] = DBLPCommand()
        registry["universities", aka: ["unis"]] = UniversitiesCommand()
        registry["gitlab"] = GitLabCommand()
        registry["perceptron"] = PerceptronCommand()
        registry["fizzbuzz"] = FizzBuzzCommand()
        registry["tictactoe"] = GameCommand<TicTacToeGame>()
        registry["uno"] = GameCommand<UnoGame>()
        registry["hangman"] = GameCommand<HangmanGame>()
        registry["wordle"] = GameCommand<WordleGame>()
        registry["solvewordle"] = SolveWordleCommand()
        registry["codenames"] = GameCommand<CodenamesGame>()
        registry["changelog", aka: ["patchnotes", "releasenotes", "commits"]] = ChangeLogCommand()
        registry["sourcefile"] = SourceFileCommand()
        registry["urbandict", aka: ["urban", "ud", "explain"]] = UrbanDictionaryCommand()
        registry["thesaurize"] = ThesaurizeCommand()
        registry["thesaurus", aka: ["synonym", "synonyms"]] = ThesaurusCommand()
        registry["imdb"] = IMDBCommand()
        registry["cocktail"] = CocktailCommand()
        registry["beer", aka: ["brewdog", "diydog"]] = BeerCommand()
        registry["openfoodfacts", aka: ["ean", "foodfacts"]] = OpenFoodFactsCommand()
        registry["recipe"] = RecipeCommand()
        registry["chess"] = GameCommand<ChessGame>()
        registry["cyclethrough"] = CycleThroughCommand()
        registry["dot", aka: ["graphviz"]] = GraphVizCommand(layout: .dot)
        registry["neato"] = GraphVizCommand(layout: .neato)
        registry["fdp"] = GraphVizCommand(layout: .fdp)
        registry["sfdp"] = GraphVizCommand(layout: .sfdp)
        registry["circo"] = GraphVizCommand(layout: .circo)
        registry["twopi"] = GraphVizCommand(layout: .twopi)
        registry["patchwork"] = GraphVizCommand(layout: .patchwork)
        registry["demoimage"] = DemoImageCommand()
        registry["demogif"] = DemoGifCommand()
        registry["giphy"] = GiphyCommand()
        registry["color"] = ColorCommand()
        registry["mandelbrot"] = MandelbrotCommand()
        registry["invertcolors"] = MapImageCommand<InvertImageMapping>(description: "Inverts every color in the image")
        registry["colortoalpha"] = MapImageCommand<ColorToAlphaImageMapping>(description: "Makes a color transparent in the image")
        registry["threshold"] = MapImageCommand<ThresholdImageMapping>(description: "Produces a black/white image with a specified luminance threshold")
        registry["watermark"] = MapImageCommand<WatermarkImageMapping>(description: "Adds a watermark to an image")
        registry["tile"] = MapImageCommand<TileImageMapping>(description: "Replicates the image along the x- or y-axis")
        registry["scaleimage", aka: ["scale"]] = MapImageCommand<ScaleImageMapping>(description: "Scales an image")
        registry["cropimage", aka: ["crop"]] = MapImageCommand<CropImageMapping>(description: "Crops an image")
        registry["ellipsemask"] = MapImageCommand<MaskImageMapping<EllipseMask>>(description: "Applies an ellipse-shaped mask to the image")
        registry["filterimage", aka: ["filter"]] = FilterImageDirectlyCommand()
        registry["boxblur"] = FilterImageCommand<BoxBlurFilter>(maxSize: 400)
        registry["gaussianblur", aka: ["blur"]] = FilterImageCommand<GaussianBlurFilter>(maxSize: 100)
        registry["sharpen"] = FilterImageCommand<SharpenFilter>(maxSize: 400)
        registry["horizontalsobeledges", aka: ["horizontaledges", "sobeledges", "sobel", "edges"]] = FilterImageCommand<SobelEdgesFilter<True>>(maxSize: 300)
        registry["verticalsobeledges", aka: ["verticaledges"]] = FilterImageCommand<SobelEdgesFilter<False>>(maxSize: 300)
        registry["emboss"] = FilterImageCommand<EmbossFilter>()
        registry["spin"] = AnimateCommand<TransformAnimation<SpinTransform>>(description: "Rotates an image")
        registry["twirl"] = AnimateCommand<TransformAnimation<TwirlTransform>>(description: "Applies a twirl distortion effect")
        registry["bump"] = AnimateCommand<TransformAnimation<RadialTransform<BumpDistortion>>>(description: "Applies a bump distortion effect")
        registry["pinch"] = AnimateCommand<TransformAnimation<RadialTransform<PinchDistortion>>>(description: "Applies an inverse bump distortion effect")
        registry["wobble"] = AnimateCommand<TransformAnimation<RadialTransform<WobbleDistortion>>>(description: "Applies a wobbling distortion effect")
        registry["warp"] = AnimateCommand<TransformAnimation<RadialTransform<WarpDistortion>>>(description: "Applies a warp distortion effect")
        registry["ripple"] = AnimateCommand<TransformAnimation<RadialTransform<RippleDistortion>>>(description: "Applies a rippling distortion effect")
        registry["squiggle"] = AnimateCommand<TransformAnimation<SquiggleTransform>>(description: "Applies a 'squiggling' distortion effect")
        registry["bounce"] = AnimateCommand<TransformAnimation<BounceTransform>>(description: "Slides the image up and down smoothly")
        registry["slide", aka: ["scroll"]] = AnimateCommand<TransformAnimation<SlideTransform>>(description: "Slides the image into a direction (by default to the right) with linear speed")
        registry["composememe", aka: ["meme", "memetemplate"]] = ComposeMemeCommand()
        registry["pingpong"] = PingPongCommand()
        registry["reverse"] = ReverseCommand()
        registry["setfps"] = SetFpsCommand()
        registry["togif"] = ToGifCommand()
        registry["framecount", aka: ["frames"]] = FrameCountCommand()
        registry["randomuser", aka: ["randommember"]] = RandomUserCommand()
        registry["avatar"] = AvatarCommand()
        registry["avatarpng", aka: ["avatarstatic"]] = AvatarCommand(preferredExtension: "png")
        registry["avatargif"] = AvatarCommand(preferredExtension: "gif")
        registry["avatarurl"] = AvatarUrlCommand()
        registry["dallemini", aka: ["dalle"]] = DallEMiniCommand()
        registry["qrcode", aka: ["qr"]] = QRCodeCommand()
        registry["latex"] = LatexCommand()
        registry["autolatex"] = AutoLatexCommand()
        registry["enterprisify"] = EnterprisifyCommand()
        registry["hoogle"] = HoogleCommand()
        registry["prolog"] = PrologCommand()
        registry["morseencode", aka: ["morse", "morsify"]] = MorseEncoderCommand()
        registry["morsedecode", aka: ["demorse", "demorsify"]] = MorseDecoderCommand()
        registry["germanencode", aka: ["german", "germanify"]] = GermanEncoderCommand()
        registry["germandecode", aka: ["degerman", "degermanify"]] = GermanDecoderCommand()
        registry["robohash"] = RoboHashCommand()
        registry["piglatin"] = PigLatinCommand()
        registry["rockpaperscissors", aka: ["rps"]] = RockPaperScissorsCommand()
        registry["dogespeak", aka: ["doge"]] = DogeSpeakCommand()
        registry["piratespeak", aka: ["pirate", "piratify"]] = PirateSpeakCommand()
        registry["mockify", aka: ["mock"]] = MockifyCommand()
        registry["leetspeak", aka: ["leet"]] = LeetSpeakCommand()
        registry["fancytext", aka: ["fancy"]] = FancyTextCommand()
        registry["rickroll"] = RickrollCommand()
        registry["micdrop"] = MicdropCommand()
        registry["love"] = LoveCommand()
        registry["triviaquiz", aka: ["trivia", "quiz"]] = TriviaQuizCommand()
        registry["pokemon"] = PokemonCommand(inventoryManager: inventoryManager)
        registry["pokedex"] = PokedexCommand()
        registry["pokequiz"] = PokeQuizCommand()
        registry["fortunecookie", aka: ["fortune"]] = FortuneCookieCommand()
        registry["iambored"] = IAmBoredCommand()
        registry["interject"] = InterjectCommand()
        registry["discordinder"] = DiscordinderCommand(inventoryManager: inventoryManager)
        registry["pickupline"] = PickupLineCommand()
        registry["chucknorrisjoke", aka: ["cnj"]] = ChuckNorrisJokeCommand()
        registry["joke"] = JokeCommand()
        registry["pat"] = PatCommand(inventoryManager: inventoryManager)
        registry["hug"] = HugCommand(inventoryManager: inventoryManager)
        registry["wouldyourather", aka: ["wyr"]] = WouldYouRatherCommand(partyGameDB: partyGameDB)
        registry["neverhaveiever", aka: ["nhie"]] = NeverHaveIEverCommand(partyGameDB: partyGameDB)
        registry["truth"] = TruthOrDareCommand(type: .truth)
        registry["dare"] = TruthOrDareCommand(type: .dare)
        registry["truthordare", aka: ["tod"]] = TruthOrDareCommand()
        registry["akinator", aka: ["20questions"]] = AkinatorCommand()
        registry["partygamedb"] = PartyGameDatabaseCommand(partyGameDB: partyGameDB)
        registry["advice"] = AdviceCommand()
        registry["agify"] = AgifyCommand()
        registry["thisforthat", aka: ["tft"]] = ThisForThatCommand()
        registry["fact"] = FactCommand()
        registry["compliment"] = ComplimentCommand()
        registry["magic8ball", aka: (1..<20).flatMap { ["\($0)ball", "\($0)b"] }] = Magic8BallCommand()
        registry["slotmachine", aka: ["slots"]] = SlotMachineCommand()
        registry["random"] = RandomCommand(permissionManager: permissionManager)
        registry["commandoftheday", aka: ["cotd"]] = CommandOfTheDayCommand(commandPrefix: commandPrefix)
        registry["commandcount", aka: ["cmdcount"]] = CommandCountCommand()
        registry["inventory"] = InventoryCommand(inventoryManager: inventoryManager)
        registry["trade"] = TradeCommand(inventoryManager: inventoryManager)
        registry["cookie"] = CookieCommand(inventoryManager: inventoryManager)
        registry["stock", aka: ["stocks", "shares"]] = StockCommand()
        registry["designquote", aka: ["quoteondesign"]] = DesignQuoteCommand()
        registry["kanyewestquote", aka: ["kanyequote"]] = KanyeWestQuoteCommand()
        registry["taylorswiftquote", aka: ["taylorquote"]] = TaylorSwiftQuoteCommand()
        registry["messagedb"] = MessageDatabaseCommand(messageDB: messageDB)
        registry["messagedbquery"] = MessageDatabaseQueryCommand(messageDB: messageDB)
        registry["messagedbvisualize"] = MessageDatabaseVisualizeCommand(messageDB: messageDB)
        registry["messagedbchannelactivity", aka: ["channelactivity"]] = MessageDatabaseChannelActivityCommand(messageDB: messageDB)
        registry["lineplot", aka: ["linegraph", "linechart", "chart", "plot"]] = LinePlotCommand()
        registry["barplot", aka: ["bargraph", "barchart", "bars", "histogram"]] = BarPlotCommand()
        registry["scatterplot", aka: ["scattergraph", "scatterchart", "scatter"]] = ScatterPlotCommand()
        registry["shell"] = ShellCommand()
        registry["upload"] = UploadCommand()
        registry["download"] = DownloadCommand()
        registry["downloadimage", aka: ["downloadimg", "di"]] = DownloadImageCommand()
        registry["markov"] = MarkovCommand(messageDB: messageDB)
        registry["conversate"] = ConversateCommand(conversator: FollowUpConversator(messageDB: messageDB))
        registry["emoji", aka: ["emote"]] = EmojiCommand()
        registry["emojis"] = EmojisCommand()
        registry["emojiusage"] = EmojiUsageCommand(messageDB: messageDB)
        registry["emojiimage", aka: ["emoteimage"]] = EmojiImageCommand()
        registry["createemoji"] = CreateEmojiCommand()
        registry["deleteemoji"] = DeleteEmojiCommand()
        registry["uwu", aka: ["owo"]] = UwUCommand()
        registry["uwuify", aka: ["owoify"]] = UwUifyCommand()
        registry["karma", aka: ["upvotes"]] = ReactionLeaderboardCommand(title: "Upvote Karma", name: "upvote", emojiName: "upvote", useReactor: false, messageDB: messageDB)
        registry["drinks"] = ReactionLeaderboardCommand(title: "Drinks", name: "drink", emojiName: "🍹", useReactor: true, messageDB: messageDB)
        registry["watch"] = WatchCommand()
        registry["regexgenerate"] = RegexGenerateCommand()
        registry["poll"] = PollCommand()
        registry["petition"] = PetitionCommand()
        registry["concat"] = ConcatCommand()
        registry["revconcat"] = ReverseConcatCommand()
        registry["repeat"] = RepeatCommand()
        registry["rev"] = ReverseInputCommand()
        registry["identity", aka: ["id"]] = IdentityCommand()
        registry["presence"] = PresenceCommand()
        registry["xkcd"] = XkcdCommand()
        registry["smbc"] = FeedCommand(url: "https://www.smbc-comics.com/comic/rss", description: "Saturday Morning Breakfast Cereal", presenter: FeedImagePresenter())
        registry["theindependent", aka: ["independent"]] = FeedCommand(url: "https://www.independent.co.uk/news/world/rss", description: "The Independent", presenter: FeedListPresenter())
        registry["tagesschau"] = FeedCommand(url: "https://www.tagesschau.de/xml/rss2_https/", description: "Tagesschau", presenter: FeedListPresenter())
        registry["spiegel"] = FeedCommand(url: "https://www.spiegel.de/schlagzeilen/tops/index.rss", description: "Spiegel Online", presenter: FeedListPresenter())
        registry["bild"] = FeedCommand(url: "https://www.bild.de/rssfeeds/rss3-20745882,feed=alles.bild.html", description: "BILD", presenter: FeedListPresenter())
        registry["sueddeutsche", aka: ["sz"]] = FeedCommand(url: "https://rss.sueddeutsche.de/rss/Topthemen", description: "Süddeutsche Zeitung", presenter: FeedListPresenter())
        registry["frankfurterallgemeine", aka: ["faz"]] = FeedCommand(url: "https://www.faz.net/rss/aktuell/", description: "Frankfurter Allgemeine Zeitung - Aktuell", presenter: FeedListPresenter())
        registry["kielernachrichten", aka: ["kn"]] = FeedCommand(url: "http://www.kn-online.de/rss/feed/kn_kiel", description: "Kieler Nachrichten", presenter: FeedListPresenter())
        registry["thenewyorktimes", aka: ["newyorktimes", "nytimes", "nyt"]] = FeedCommand(url: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", description: "New York Times - Top Stories", presenter: FeedListPresenter())
        registry["thewallstreetjournal", aka: ["wallstreetjournal", "wsj"]] = FeedCommand(url: "https://feeds.a.dj.com/rss/RSSWorldNews.xml", description: "The Wall Street Journal", presenter: FeedListPresenter())
        registry["theguardian"] = FeedCommand(url: "https://www.theguardian.com/world/rss", description: "The Guardian - World News", presenter: FeedListPresenter())
        registry["theeconomist", aka: ["economist"]] = FeedCommand(url: "https://www.economist.com/international/rss.xml", description: "The Economist - International", presenter: FeedListPresenter())
        registry["bbc"] = FeedCommand(url: "https://feeds.bbci.co.uk/news/rss.xml", description: "BBC News - Top Stories", presenter: FeedListPresenter())
        registry["cnn"] = FeedCommand(url: "http://rss.cnn.com/rss/edition.rss", description: "CNN", presenter: FeedListPresenter())
        registry["washingtonpost"] = FeedCommand(url: "http://feeds.washingtonpost.com/rss/world", description: "Washington Post - World", presenter: FeedListPresenter())
        registry["hackernews", aka: ["hn"]] = FeedCommand(url: "https://hnrss.org/frontpage", description: "Hacker News: Front Page", presenter: FeedListPresenter())
        registry["nasa"] = FeedCommand(url: "https://www.nasa.gov/rss/dyn/breaking_news.rss", description: "NASA: Breaking News", presenter: FeedListPresenter())
        registry["nasaimage"] = FeedCommand(url: "https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss", description: "NASA: Image of the Day", presenter: FeedImagePresenter())
        registry["bingimage"] = FeedCommand(url: "https://www.bing.com/HPImageArchive.aspx?format=rss&idx=0&n=1&mkt=en-US", description: "Bing's Image of the Day", presenter: FeedImagePresenter())
        registry["derpostillon", aka: ["postillon"]] = FeedCommand(url: "http://feeds.feedburner.com/blogspot/rkEL", description: "Der Postillon", presenter: FeedListPresenter())
        registry["theonion"] = FeedCommand(url: "https://www.theonion.com/rss", description: "The Onion", presenter: FeedListPresenter())
        registry["financialtimes", aka: ["ft"]] = FeedCommand(url: "https://www.ft.com/?format=rss", description: "Financial Times", presenter: FeedListPresenter())
        registry["dagensnyheter", aka: ["dn"]] = FeedCommand(url: "https://www.dn.se/nyheter/m/rss/", description: "Dagens Nyheter", presenter: FeedListPresenter())
        registry["lemonde"] = FeedCommand(url: "https://www.lemonde.fr/rss/une.xml", description: "Le Monde", presenter: FeedListPresenter())
        registry["elpais"] = FeedCommand(url: "https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/portada", description: "EL PAÍS", presenter: FeedListPresenter())
        registry["losangelestimes", aka: ["latimes", "lat"]] = FeedCommand(url: "https://www.latimes.com/world-nation/rss2.0.xml", description: "Los Angeles Times", presenter: FeedListPresenter())
        registry["astronomypictureoftheday", aka: ["apod"]] = NasaAstronomyPictureOfTheDayCommand()
        registry["coinflip", aka: ["coin"]] = CoinFlipCommand()
        registry["diceroll", aka: ["dice", "roll"]] = DiceRollCommand(1...6)
        registry["pickrandom", aka: ["pick"]] = PickRandomCommand()
        registry["pickprogramminglanguage", aka: ["picklanguage", "picklang"]] = PickProgrammingLanguageCommand()
        registry["directmessage", aka: ["dm", "whisper"]] = DirectMessageCommand()
        registry["react"] = ReactCommand()
        registry["temporaryreact", aka: ["tempreact", "tmpreact", "tr"]] = ReactCommand(temporary: true)
        registry["channelmessage", aka: ["m"]] = ChannelMessageCommand()
        registry["asciiart", aka: ["ascii"]] = AsciiArtCommand()
        registry["tofile"] = ToFileCommand()
        registry["cleanmentions"] = CleanMentionsCommand()
        registry["chord"] = FretboardChordCommand()
        registry["chords"] = LyricsCommand(showChords: true)
        registry["transposechords", aka: ["transposenotes", "transposemusic"]] = TransposeChordsCommand()
        registry["findkey", aka: ["guesskey"]] = FindKeyCommand()
        registry["lyrics"] = LyricsCommand(showChords: false)
        registry["pianoscale", aka: ["piano"]] = PianoScaleCommand()
        registry["web"] = WebCommand()
        registry["get"] = HTTPRequestCommand(method: "GET")
        registry["post"] = HTTPRequestCommand(method: "POST")
        registry["put"] = HTTPRequestCommand(method: "PUT")
        registry["patch"] = HTTPRequestCommand(method: "PATCH")
        registry["delete"] = HTTPRequestCommand(method: "DELETE")
        registry["parsedom", aka: ["parsehtml"]] = ParseDOMCommand()
        registry["cssselect", aka: ["cssselector", "selector", "select"]] = CSSSelectorCommand()
        registry["geocode", aka: ["geo", "geocoords", "coords"]] = GeocodeCommand()
        registry["geoip"] = GeoIPCommand()
        registry["speedtest", aka: ["speed", "networkspeed", "fast"]] = SpeedtestCommand()
        registry["tiervehicles", aka: ["tier", "tierscooters"]] = TierVehiclesCommand()
        registry["guildicon", aka: ["icon", "guildimage", "servericon", "serveravatar", "serverimage"]] = GuildIconCommand()
        registry["guildinfo", aka: ["stats", "server", "serverstats", "serverinfo", "guild", "guildstats"]] = GuildInfoCommand(messageDB: messageDB)
        registry["guildchannels", aka: ["channels", "serverchannels"]] = GuildChannelsCommand()
        registry["peekchannel", aka: ["peek", "peekmessages"]] = PeekChannelCommand()
        registry["pronouns"] = PronounsCommand($config: $pronounRoleConfiguration)
        registry["pronounrole"] = PronounRoleCommand($config: $pronounRoleConfiguration)
        registry["guilds"] = GuildsCommand()
        registry["searchchannel", aka: ["findchannel", "sc"]] = SearchChannelCommand()
        registry["whatsup"] = WhatsUpCommand()
        registry["songcharts"] = SongChartsCommand()
        registry["adventofcode", aka: ["aoc"]] = AdventOfCodeCommand()
        registry["tldr", aka: ["summarize", "summary"]] = TLDRCommand()
        registry["sortby"] = SortByCommand()
        registry["addscript"] = AddD2ScriptCommand()
        registry["discordstatus"] = DiscordStatusCommand()
        registry["ioplatform"] = IOPlatformCommand()
        registry["sysinfo"] = SysInfoCommand()
        registry["debugmessage", aka: ["debug"]] = DebugMessageCommand()
        registry["debugweatherreactions", aka: ["debugweather"]] = DebugWeatherReactionsCommand()
        registry["issuereport", aka: ["bugreport"]] = IssueReportCommand()
        registry["techsupport", aka: ["helpme", "helpmenowplz"]] = TechSupportCommand(permissionManager: permissionManager)
        registry["about"] = AboutCommand(commandPrefix: commandPrefix)
        registry["uptime"] = UptimeCommand()
        registry["restarts"] = RestartsCommand(hostInfo: hostInfo)
        registry["search", aka: ["s"]] = SearchCommand(commandPrefix: commandPrefix, permissionManager: permissionManager)
        registry["rerun", aka: ["re"]] = ReRunCommand(permissionManager: permissionManager, mostRecentPipeRunner: _mostRecentPipeRunner)
        registry["help", aka: ["h"]] = HelpCommand(commandPrefix: commandPrefix, permissionManager: permissionManager)
    }

    public func on(receiveReady: [String: Any], sink: any Sink) {
        // TODO: Make on(receiveReady:) itself (and the other methods) async in
        // the protocol and remove this explicit Task.
        Task {
            let guildCount = sink.guilds?.count ?? 0
            log.info("Received ready! \(guildCount) \("guild".pluralized(with: guildCount)) found.")

            if let presence = initialPresence {
                do {
                    try await sink.setPresence(PresenceUpdate(activities: [Presence.Activity(name: presence, type: .listening)], status: .online))
                } catch {
                    log.warning("Could not set presence: \(error)")
                }
            }

            eventListenerBus.fire(event: .receiveReady, with: .none) // TODO: Pass data?

            do {
                try messageDB.setupTables(sink: sink)
            } catch {
                log.warning("Could not setup message database: \(error)")
            }

            do {
                try partyGameDB.setupTables()
            } catch {
                log.warning("Could not setup party game database: \(error)")
            }

            if useMIOCommands {
                // Register the commands e.g. using Discord's slash-command API
                // providing basic auto-completion for registered commands.
                var registeredCount = 0
                let groupedCommands = Dictionary(grouping: registry.commandsWithAliases(), by: \.command.info.category)

                for (category, cmds) in groupedCommands where category.rawValue.count >= 3 {
                    let shownCmds = cmds
                        .sorted(by: ascendingComparator { $0.command.info.requiredPermissionLevel.rawValue })
                        .filter { $0.command.info.presented }
                        .prefix(10)

                    let options = shownCmds
                        .map {
                            MIOCommand.Option(
                                type: .subCommand,
                                name: ([$0.name] + $0.aliases).first { (3..<32).contains($0.count) } ?? $0.name.truncated(to: 28, appending: "..."),
                                description: $0.command.info.shortDescription,
                                options: $0.command.inputValueType == .text
                                    ? [.init(
                                        type: .string,
                                        name: "input",
                                        description: $0.command.info.helpText?.split(separator: "\n").map(String.init).first
                                            ?? "Arguments to pass to the command",
                                        isRequired: false
                                    )]
                                    : []
                            )
                        }

                    do {
                        if let guildId = mioCommandGuildId {
                            // Only register MIO commands on guild, if specified
                            // (useful for development)
                            try await sink.createMIOCommand(
                                on: guildId,
                                name: category.rawValue,
                                description: category.plainDescription,
                                options: options
                            )
                        } else {
                            // Register MIO commands globally
                            try await sink.createMIOCommand(
                                name: category.rawValue,
                                description: category.plainDescription,
                                options: options
                            )
                        }
                    } catch {
                        log.warning("Could not create MIO commands: \(error)")
                    }
                    registeredCount += 1
                }

                log.info("Registered \(registeredCount) \("command".pluralized(with: registeredCount)) as MIO commands")
            } else {
                log.info("Skipping initializion of MIO commands")
            }
        }
    }

    public func on(receivePresenceUpdate presence: Presence, sink: any Sink) {
        // TODO: Remove Task once on(receivePresenceUpdate:) is async
        Task {
            for (_, entry) in registry {
                if case let .command(command) = entry {
                    await command.onReceivedUpdated(presence: presence)
                }
            }

            for i in presenceHandlers.indices {
                await presenceHandlers[i].handle(presenceUpdate: presence, sink: sink)
            }

            // TODO: Pass full presence?
            eventListenerBus.fire(event: .receivePresenceUpdate, with: presence.activities.first.map { RichValue.text($0.name) } ?? .none)
        }
    }

    public func on(createGuild guild: Guild, sink: any Sink) {
        // TODO: Remove Task once on(createGuild:) is async
        Task {
            do {
                log.info("Inserting guild '\(guild.name)' into message database...")
                try messageDB.insert(guild: guild)
            } catch {
                log.warning("Could not insert guild into message database: \(error)")
            }

            for (_, presence) in guild.presences {
                for i in presenceHandlers.indices {
                    await presenceHandlers[i].handle(presenceUpdate: presence, sink: sink)
                }
            }

            eventListenerBus.fire(event: .createGuild, with: .none) // TODO: Provide guild ID?
        }
    }

    public func on(createMessage message: Message, sink: any Sink) {
        // TODO: Make on(createMessage:) itself (and the other methods) async in
        // the protocol and remove this explicit Task.
        Task {
            var m = message

            for rewriter in messageRewriters {
                if let rewrite = await rewriter.rewrite(message: m, sink: sink) {
                    m = rewrite
                }
            }

            for i in messageHandlers.indices {
                if await messageHandlers[i].handleRaw(message: message, sink: sink) {
                    return
                }
                if await messageHandlers[i].handle(message: m, sink: sink) {
                    return
                }
            }

            // Only fire on unhandled messages
            if m.author?.id != sink.me?.id {
                let value = await MessageParser().parse(message: m, clientName: sink.name, guild: m.guild)
                eventListenerBus.fire(event: .createMessage, with: value, context: CommandContext(
                    sink: sink,
                    registry: self.registry,
                    message: m,
                    commandPrefix: self.commandPrefix,
                    hostInfo: self.hostInfo,
                    subscriptions: .init(),
                    eventLoopGroup: self.eventLoopGroup
                ))
            }
        }
    }

    public func on(createInteraction interaction: Interaction, sink: any Sink) {
        // TODO: Make on(createInteraction:) itself (and the other methods)
        // async in the protocol and remove this explicit Task.
        Task {
            for i in interactionHandlers.indices {
                if await interactionHandlers[i].handle(interaction: interaction, sink: sink) {
                    return
                }
            }
        }
    }

    public func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) {
        // TODO: Make on(addReaction:) itself (and the other methods)
        // async in the protocol and remove this explicit Task.
        Task {
            for i in reactionHandlers.indices {
                await reactionHandlers[i].handle(createdReaction: reaction, to: messageId, on: channelId, by: userId, sink: sink)
            }
        }
    }

    public func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) {
        // TODO: Make on(removeReaction:) itself (and the other methods)
        // async in the protocol and remove this explicit Task.
        Task {
            for i in reactionHandlers.indices {
                await reactionHandlers[i].handle(deletedReaction: reaction, from: messageId, on: channelId, by: userId, sink: sink)
            }
        }
    }

    public func on(removeAllReactionsFrom messageId: MessageID, on channelId: ChannelID, sink: any Sink) {
        // TODO: Make on(removeAllReactionsFrom:) itself (and the other methods)
        // async in the protocol and remove this explicit Task.
        Task {
            for i in reactionHandlers.indices {
                await reactionHandlers[i].handle(deletedAllReactionsFrom: messageId, on: channelId, sink: sink)
            }
        }
    }

    public func on(updateMessage message: Message, sink: any Sink) {
        // TODO: Make on(updateMessage:) itself (and the other methods)
        // async in the protocol and remove this explicit Task.
        Task {
            let value = await MessageParser().parse(message: message, clientName: sink.name, guild: message.guild)
            self.eventListenerBus.fire(event: .updateMessage, with: value, context: CommandContext(
                sink: sink,
                registry: self.registry,
                message: message,
                commandPrefix: self.commandPrefix,
                hostInfo: self.hostInfo,
                subscriptions: .init(),
                eventLoopGroup: self.eventLoopGroup
            ))
        }
    }

    public func on(disconnectWithReason reason: String, sink: any Sink) {
        fatalError("Disconnected with reason: \(reason)")
    }

    public func on(createChannel channel: Channel, sink: any Sink) {
        for i in channelHandlers.indices {
            channelHandlers[i].handle(channelCreate: channel, sink: sink)
        }

        eventListenerBus.fire(event: .createChannel, with: .none) // TODO: Pass channel ID?
    }

    public func on(deleteChannel channel: Channel, sink: any Sink) {
        for i in channelHandlers.indices {
            channelHandlers[i].handle(channelDelete: channel, sink: sink)
        }

        eventListenerBus.fire(event: .deleteChannel, with: .none) // TODO: Pass channel ID?
    }

    public func on(updateChannel channel: Channel, sink: any Sink) {
        for i in channelHandlers.indices {
            channelHandlers[i].handle(channelUpdate: channel, sink: sink)
        }

        eventListenerBus.fire(event: .updateChannel, with: .none) // TODO: Pass channel ID?
    }

    public func on(createThread thread: Channel, sink: any Sink) {
        for i in channelHandlers.indices {
            channelHandlers[i].handle(threadCreate: thread, sink: sink)
        }
    }

    public func on(deleteThread thread: Channel, sink: any Sink) {
        for i in channelHandlers.indices {
            channelHandlers[i].handle(threadDelete: thread, sink: sink)
        }
    }

    public func on(updateThread thread: Channel, sink: any Sink) {
        for i in channelHandlers.indices {
            channelHandlers[i].handle(threadUpdate: thread, sink: sink)
        }
    }

    public func on(deleteGuild guild: Guild, sink: any Sink) {
        eventListenerBus.fire(event: .deleteGuild, with: .none) // TODO: Pass guild ID?
    }

    public func on(updateGuild guild: Guild, sink: any Sink) {
        do {
            log.info("Updating guild '\(guild.name)' in message database...")
            try messageDB.insert(guild: guild)
        } catch {
            log.warning("Could not update guild in message database: \(error)")
        }

        eventListenerBus.fire(event: .updateGuild, with: .none) // TODO: Pass guild ID?
    }

    public func on(addGuildMember member: Guild.Member, sink: any Sink) {
        do {
            if let guild = sink.guild(for: member.guildId) {
                log.info("Inserting member '\(member.displayName)' into message database...")
                try messageDB.insert(member: member, on: guild)
            }
        } catch {
            log.warning("Could not insert member into message database: \(error)")
        }

        eventListenerBus.fire(event: .addGuildMember, with: .mentions([member.user]))
    }

    public func on(removeGuildMember member: Guild.Member, sink: any Sink) {
        eventListenerBus.fire(event: .removeGuildMember, with: .mentions([member.user]))
    }

    public func on(updateGuildMember member: Guild.Member, sink: any Sink) {
        do {
            if let guild = sink.guild(for: member.guildId) {
                log.info("Updating member '\(member.displayName)' in message database...")
                try messageDB.insert(member: member, on: guild)
            }
        } catch {
            log.warning("Could not update member in message database: \(error)")
        }

        eventListenerBus.fire(event: .updateGuildMember, with: .mentions([member.user]))
    }

    public func on(createRole role: Role, on guild: Guild, sink: any Sink) {
        do {
            log.info("Inserting role '\(role.name)' on '\(guild.name)' into message database...")
            try messageDB.insert(role: role, on: guild)
        } catch {
            log.warning("Could not insert role into message database: \(error)")
        }

        eventListenerBus.fire(event: .createRole, with: .none) // TODO: Pass role ID/role mention?
    }

    public func on(deleteRole role: Role, from guild: Guild, sink: any Sink) {
        eventListenerBus.fire(event: .deleteRole, with: .none) // TODO: Pass role ID/role mention?
    }

    public func on(updateRole role: Role, on guild: Guild, sink: any Sink) {
        do {
            log.info("Updating role '\(role.name)' on '\(guild.name)' in message database...")
            try messageDB.insert(role: role, on: guild)
        } catch {
            log.warning("Could not update role in message database: \(error)")
        }

        eventListenerBus.fire(event: .updateRole, with: .none) // TODO: Pass role ID/role mention?
    }

    public func on(connect connected: Bool, sink: any Sink) {
        eventListenerBus.fire(event: .connect, with: .none) // TODO: Pass 'connected'?
    }

    public func on(receiveVoiceStateUpdate state: VoiceState, sink: any Sink) {
        eventListenerBus.fire(event: .receiveVoiceStateUpdate, with: .none) // TODO: Pass state?
    }

    public func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, sink: any Sink) {
        eventListenerBus.fire(event: .handleGuildMemberChunk, with: .none) // TODO: Pass state?
    }

    public func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, sink: any Sink) {
        do {
            log.info("Updating emojis on '\(guild.name)' in message database...")
            for emoji in emojis.values {
                try messageDB.insert(emoji: emoji)
            }
        } catch {
            log.warning("Could not update emojis in message database: \(error)")
        }

        eventListenerBus.fire(event: .updateEmojis, with: .none) // TODO: Pass emojis, possibly by creating a RichValue.emoji variant
    }
}
