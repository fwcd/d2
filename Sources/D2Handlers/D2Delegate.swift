import D2MessageIO
import Foundation
import Logging
import Utils
import D2Commands
import D2Permissions

fileprivate let log = Logger(label: "D2Handlers.D2Delegate")

/** A client delegate that dispatches commands. */
public class D2Delegate: MessageDelegate {
    private let commandPrefix: String
    private let initialPresence: String?
    private let useMIOCommands: Bool
    private let mioCommandGuildId: GuildID?

    private let messageDB: MessageDatabase
    private let partyGameDB: PartyGameDatabase
    private let registry: CommandRegistry
    private let eventListenerBus: EventListenerBus
    private let subscriptionManager: SubscriptionManager
    private let permissionManager: PermissionManager

    private var messageRewriters: [MessageRewriter]
    private var messageHandlers: [MessageHandler]
    private var reactionHandlers: [ReactionHandler]
    private var presenceHandlers: [PresenceHandler]

    public init(
        withPrefix commandPrefix: String,
        initialPresence: String? = nil,
        useMIOCommands: Bool = false,
        mioCommandGuildId: GuildID? = nil
    ) throws {
        self.commandPrefix = commandPrefix
        self.initialPresence = initialPresence
        self.useMIOCommands = useMIOCommands
        self.mioCommandGuildId = mioCommandGuildId

        registry = CommandRegistry()
        messageDB = try MessageDatabase()
        partyGameDB = try PartyGameDatabase()
        eventListenerBus = EventListenerBus()
        subscriptionManager = SubscriptionManager(registry: registry)
        permissionManager = PermissionManager()
        let mostRecentPipeRunner = Synchronized(wrappedValue: Box<(Runnable, PermissionLevel)?>(wrappedValue: nil))
        let spamConfiguration = AutoSerializing<SpamConfiguration>(wrappedValue: .init(), filePath: "local/spamConfig.json")
        let streamerRoleConfiguration = AutoSerializing<StreamerRoleConfiguration>(wrappedValue: .init(), filePath: "local/streamerRoleConfig.json")
        let messagePreviewsConfiguration = AutoSerializing<MessagePreviewsConfiguration>(wrappedValue: .init(), filePath: "local/messagePreviewsConfig.json")
        let haikuConfiguration = AutoSerializing<HaikuConfiguration>(wrappedValue: .init(), filePath: "local/haikuConfig.json")
        let roleReactionsConfiguration = AutoSerializing<RoleReactionsConfiguration>(wrappedValue: .init(), filePath: "local/roleReactionsConfig.json")
        let inventoryManager = InventoryManager()

        messageRewriters = [
            MentionSomeoneRewriter()
        ]
        messageHandlers = [
            SpamHandler(config: spamConfiguration),
            CommandHandler(commandPrefix: commandPrefix, registry: registry, permissionManager: permissionManager, subscriptionManager: subscriptionManager, mostRecentPipeRunner: mostRecentPipeRunner),
            SubscriptionHandler(commandPrefix: commandPrefix, registry: registry, manager: subscriptionManager),
            MentionD2Handler(conversator: FollowUpConversator(messageDB: messageDB)),
            MentionSomeoneHandler(),
            HaikuHandler(configuration: haikuConfiguration, inventoryManager: inventoryManager),
            MessagePreviewHandler(configuration: messagePreviewsConfiguration),
            TriggerReactionHandler(),
            CountToNHandler(),
            MessageDatabaseHandler(messageDB: messageDB) // Below other handlers so as to not pick up on commands
        ]
        reactionHandlers = [
            RoleReactionHandler(configuration: roleReactionsConfiguration),
            SubscriptionReactionHandler(commandPrefix: commandPrefix, registry: registry, manager: subscriptionManager),
            MessageDatabaseReactionHandler(messageDB: messageDB)
        ]
        presenceHandlers = [
            StreamerRoleHandler(streamerRoleConfiguration: streamerRoleConfiguration)
        ]

        registry["ping"] = PingCommand()
        registry["beep"] = PingCommand(response: "Bop")
        registry["vertical"] = VerticalCommand()
        registry["bf"] = BFCommand()
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
        registry["weather"] = WeatherCommand()
        registry["sunrisesunset", aka: ["sunrise", "sunset", "twilight", "dawn", "dusk"]] = SunriseSunsetCommand()
        registry["webcam"] = WebcamCommand()
        registry["mdb"] = MDBCommand()
        registry["timetable"] = TimeTableCommand()
        registry["univis"] = UnivISCommand()
        registry["mensa"] = MensaCommand()
        registry["yo"] = YoCommand()
        registry["countdown", aka: ["countdowns", "events"]] = CountdownCommand(builtInGoals: ["Christmas Eve": ChristmasEveGoal(), "New Year's Eve": NewYearsEveGoal()])
        registry["reddit", aka: ["r", "sub", "subreddit"]] = RedditCommand(presenter: RedditFeedPresenter())
        registry["redditpost", aka: ["rp"]] = RedditCommand(presenter: RedditPostPresenter())
        registry["grant"] = GrantPermissionCommand(permissionManager: permissionManager)
        registry["revoke"] = RevokePermissionCommand(permissionManager: permissionManager)
        registry["simulate"] = SimulatePermissionCommand(permissionManager: permissionManager)
        registry["spammerrole"] = SpammerRoleCommand(spamConfiguration: spamConfiguration)
        registry["streamerrole", aka: ["twitchrole"]] = StreamerRoleCommand(streamerRoleConfiguration: streamerRoleConfiguration)
        registry["messagepreviews"] = MessagePreviewsCommand(configuration: messagePreviewsConfiguration)
        registry["haikus"] = HaikusCommand(configuration: haikuConfiguration)
        registry["permissions"] = ShowPermissionsCommand(permissionManager: permissionManager)
        registry["userinfo", aka: ["user"]] = UserInfoCommand()
        registry["clear"] = ClearCommand()
        registry["rolereactions"] = RoleReactionsCommand(configuration: roleReactionsConfiguration)
        registry["logs"] = LogsCommand()
        registry["for"] = ForCommand()
        registry["do"] = DoCommand()
        registry["quit"] = QuitCommand()
        registry["blockforever", aka: ["block"]] = BlockForeverCommand()
        registry["removeallmiocommands"] = RemoveAllMIOCommandsCommand()
        registry["grep"] = GrepCommand()
        registry["author"] = AuthorCommand()
        registry["addeventlistener", aka: ["on"]] = AddEventListenerCommand(eventListenerBus: eventListenerBus)
        registry["removeeventlistener", aka: ["off"]] = RemoveEventListenerCommand(eventListenerBus: eventListenerBus)
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
        registry["codenames"] = GameCommand<CodenamesGame>()
        registry["changelog", aka: ["patchnotes", "releasenotes", "commits"]] = ChangeLogCommand()
        registry["sourcefile"] = SourceFileCommand()
        registry["urbandict", aka: ["urban", "ud", "explain"]] = UrbanDictionaryCommand()
        registry["thesaurize"] = ThesaurizeCommand()
        registry["thesaurus", aka: ["synonym", "synonyms"]] = ThesaurusCommand()
        registry["imdb"] = IMDBCommand()
        registry["cocktail"] = CocktailCommand()
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
        registry["ocr"] = OCRCommand()
        registry["qr"] = QRCommand()
        registry["latex"] = LatexCommand()
        registry["autolatex"] = AutoLatexCommand()
        registry["enterprisify"] = EnterprisifyCommand()
        registry["hoogle"] = HoogleCommand()
        registry["haskell"] = HaskellCommand()
        registry["pointfree"] = PointfreeCommand()
        registry["pointful"] = PointfulCommand()
        registry["prolog"] = PrologCommand()
        registry["morseencode", aka: ["morse", "morsify"]] = MorseEncoderCommand()
        registry["morsedecode", aka: ["demorse", "demorsify"]] = MorseDecoderCommand()
        registry["germanencode", aka: ["german", "germanify"]] = GermanEncoderCommand()
        registry["germandecode", aka: ["degerman", "degermanify"]] = GermanDecoderCommand()
        registry["robohash"] = RoboHashCommand()
        registry["piglatin"] = PigLatinCommand()
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
        registry["discordinder"] = DiscordinderCommand(inventoryManager: inventoryManager)
        registry["pickupline"] = PickupLineCommand()
        registry["chucknorrisjoke", aka: ["cnj"]] = ChuckNorrisJokeCommand()
        registry["joke"] = JokeCommand()
        registry["pat"] = PatCommand(inventoryManager: inventoryManager)
        registry["hug"] = HugCommand(inventoryManager: inventoryManager)
        registry["wouldyourather", aka: ["wyr"]] = WouldYouRatherCommand(partyGameDB: partyGameDB)
        registry["neverhaveiever", aka: ["nhie"]] = NeverHaveIEverCommand(partyGameDB: partyGameDB)
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
        registry["designquote", aka: ["quoteondesign"]] = DesignQuoteCommand()
        registry["kanyewestquote", aka: ["kanyequote"]] = KanyeWestQuoteCommand()
        registry["taylorswiftquote", aka: ["taylorquote"]] = TaylorSwiftQuoteCommand()
        registry["messagedb"] = MessageDatabaseCommand(messageDB: messageDB)
        registry["messagedbquery"] = MessageDatabaseQueryCommand(messageDB: messageDB)
        registry["messagedbvisualize"] = MessageDatabaseVisualizeCommand(messageDB: messageDB)
        registry["messagedbchannelactivity", aka: ["channelactivity"]] = MessageDatabaseChannelActivityCommand(messageDB: messageDB)
        registry["lineplot", aka: ["linegraph", "plot"]] = LinePlotCommand()
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
        registry["thetelegraph", aka: ["telegraph"]] = FeedCommand(url: "https://www.telegraph.co.uk/rss.xml", description: "The Telegraph", presenter: FeedListPresenter())
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
        registry["coinflip", aka: ["coin"]] = CoinFlipCommand()
        registry["diceroll", aka: ["dice", "roll"]] = DiceRollCommand(1...6)
        registry["pickrandom", aka: ["pick"]] = PickRandomCommand()
        registry["pickprogramminglanguage", aka: ["picklanguage", "picklang"]] = PickProgrammingLanguageCommand()
        registry["directmessage", aka: ["dm", "whisper"]] = DirectMessageCommand()
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
        registry["tiervehicles", aka: ["tier", "tierscooters"]] = TierVehiclesCommand()
        registry["guildicon", aka: ["icon", "guildimage", "servericon", "serveravatar", "serverimage"]] = GuildIconCommand()
        registry["guildinfo", aka: ["stats", "server", "serverstats", "serverinfo", "guild", "guildstats"]] = GuildInfoCommand(messageDB: messageDB)
        registry["guildchannels", aka: ["channels", "serverchannels"]] = GuildChannelsCommand()
        registry["peekchannel", aka: ["peek", "peekmessages"]] = PeekChannelCommand()
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
        registry["issuereport", aka: ["bugreport"]] = IssueReportCommand()
        registry["techsupport", aka: ["helpme", "helpmenowplz"]] = TechSupportCommand(permissionManager: permissionManager)
        registry["about"] = AboutCommand(commandPrefix: commandPrefix)
        registry["search", aka: ["s"]] = SearchCommand(commandPrefix: commandPrefix, permissionManager: permissionManager)
        registry["rerun", aka: ["re"]] = ReRunCommand(permissionManager: permissionManager, mostRecentPipeRunner: mostRecentPipeRunner)
        registry["help", aka: ["h"]] = HelpCommand(commandPrefix: commandPrefix, permissionManager: permissionManager)
    }

    public func on(receiveReady: [String: Any], client: MessageClient) {
        let guildCount = client.guilds?.count ?? 0
        log.info("Received ready! \(guildCount) \("guild".pluralized(with: guildCount)) found.")

        if let presence = initialPresence {
            client.setPresence(PresenceUpdate(game: Presence.Activity(name: presence, type: .listening)))
        }

        eventListenerBus.fire(event: .receiveReady, with: .none) // TODO: Pass data?

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

        if useMIOCommands {
            // Register the commands e.g. using Discord's slash-command API
            // providing basic auto-completion for registered commands.
            var registeredCount = 0
            let groupedCommands = Dictionary(grouping: registry.commandsWithAliases(), by: \.command.info.category)

            for (category, cmds) in groupedCommands {
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

                if let guildId = mioCommandGuildId {
                    // Only register MIO commands on guild, if specified
                    // (useful for development)
                    client.createMIOCommand(
                        on: guildId,
                        name: category.rawValue,
                        description: category.plainDescription,
                        options: options
                    )
                } else {
                    // Register MIO commands globally
                    client.createMIOCommand(
                        name: category.rawValue,
                        description: category.plainDescription,
                        options: options
                    )
                }
                registeredCount += 1
            }

            log.info("Registered \(registeredCount) \("command".pluralized(with: registeredCount)) as MIO commands")
        } else {
            log.info("Skipping initializion of MIO commands")
        }
    }

    public func on(receivePresenceUpdate presence: Presence, client: MessageClient) {
        for (_, entry) in registry {
            if case let .command(command) = entry {
                command.onReceivedUpdated(presence: presence)
            }
        }

        for (i, _) in presenceHandlers.enumerated() {
            presenceHandlers[i].handle(presenceUpdate: presence, client: client)
        }

        eventListenerBus.fire(event: .receivePresenceUpdate, with: presence.game.map { RichValue.text($0.name) } ?? .none) // TODO: Pass full presence?
    }

    public func on(createGuild guild: Guild, client: MessageClient) {
        do {
            try messageDB.insert(guild: guild)
        } catch {
            log.warning("Could not insert guild into message database: \(error)")
        }

        for (_, presence) in guild.presences {
            for (i, _) in presenceHandlers.enumerated() {
                presenceHandlers[i].handle(presenceUpdate: presence, client: client)
            }
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
            MessageParser().parse(message: m, clientName: client.name, guild: m.guild).listenOrLogError {
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

    public func on(createInteraction interaction: Interaction, client: MessageClient) {
        // TODO: Factor out this logic into InteractionHandlers

        guard
            useMIOCommands,
            interaction.type == .mioCommand,
            let data = interaction.data else { return }

        let content = data.options.compactMap { $0.value as? String }.joined(separator: " ")
        let input = RichValue.text(content)
        let context = CommandContext(
            client: client,
            registry: registry,
            message: Message(
                content: content,
                author: interaction.member?.user,
                channelId: interaction.channelId,
                guild: interaction.guildId.flatMap(client.guild(for:)),
                guildMember: interaction.member
            ),
            commandPrefix: commandPrefix,
            subscriptions: .init() // TODO: Support subscriptions here
        )
        let output = MessageIOInteractionOutput(interaction: interaction, context: context)

        guard let author = interaction.member?.user else {
            output.append(errorText: "The interaction must have an author!")
            return
        }
        guard let command = registry[data.name] else {
            output.append(errorText: "Unknown command name `\(data.name)`")
            return
        }
        guard permissionManager.user(author, hasPermission: command.info.requiredPermissionLevel, usingSimulated: command.info.usesSimulatedPermissionLevel) else {
            output.append(errorText: "Insufficient permissions, sorry. :(")
            return
        }

        command.invoke(with: input, output: output, context: context)
    }

    public func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {
        for (i, _) in reactionHandlers.enumerated() {
            reactionHandlers[i].handle(createdReaction: reaction, to: messageId, on: channelId, by: userId, client: client)
        }
    }

    public func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {
        for (i, _) in reactionHandlers.enumerated() {
            reactionHandlers[i].handle(deletedReaction: reaction, from: messageId, on: channelId, by: userId, client: client)
        }
    }

    public func on(removeAllReactionsFrom messageId: MessageID, on channelId: ChannelID, client: MessageClient) {
        for (i, _) in reactionHandlers.enumerated() {
            reactionHandlers[i].handle(deletedAllReactionsFrom: messageId, on: channelId, client: client)
        }
    }

    public func on(updateMessage message: Message, client: MessageClient) {
        MessageParser().parse(message: message, clientName: client.name, guild: message.guild).listenOrLogError {
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

    public func on(connect connected: Bool, client: MessageClient) {
        eventListenerBus.fire(event: .connect, with: .none) // TODO: Pass 'connected'?
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
