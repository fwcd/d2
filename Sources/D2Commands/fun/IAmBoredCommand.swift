import Utils

public class IAmBoredCommand: VoidCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Suggests something to do if you are bored!",
        requiredPermissionLevel: .basic
    )
    private let verbs: [String]
    private let things: [String]
    private let methods: [String]
    private let templates: [String]

    public init(
        verbs: [String] = ["solve", "play", "build", "compose", "draw", "write", "fix", "rap", "sing", "catch", "open", "press", "sleep on", "eat", "craft", "design", "read", "stream", "watch", "interpret", "analyze", "record", "create", "make", "learn making", "find", "invent", "assemble", "google", "cook", "dream of", "code", "describe", "build a startup dealing with", "create an open-source-project from", "publish", "sell", "think of", "build a machine that creates", "train a neural network that makes", "collect", "predict", "search for", "perform", "buy", "twitter", "3D-print", "share", "post"],
        things: [String] = ["a guitar", "a new game", "a song", "a fish", "a button", "a program", "a box", "a crossword puzzle", "a book", "a Wikipedia article", "a YouTube video", "a lamp", "a movie", "a compiler", "a hat", "a drawing", "an instrument", "a crazy idea", "a flower", "a mathematical problem", "a football", "a machine", "a poem", "a story", "music", "art", "abstract art", "a composition", "your homework", "food", "a piano", "classical music", "pop music", "stickers", "messages", "ideas", "the weather", "experiments", "a dance", "the newest title on Steam", "a Pokémon character", "interesting ideas", "chess pieces", "a card game", "a joke", "something", "a lyrical masterpiece", "the next blockbuster", "your favorite song", "an app", "fashion", "a movie trailer"],
        methods: [String] = ["a pencil", "a keyboard", "your finger", "your imagination", "a friend", "a wrench", "your hand", "a computer", "your voice", "a fishing rod", "a spoon", "a phone", "a paperclip", "a tv", "a microphone", "a stick", "a potato", "an instrument", "a piano", "drums", "a Raspberry Pi", "a hammer and a chisel", "a dj"],
        templates: [String] = ["Why don't you % % with %?", "Try to % % with %!", "You could % % with %!", "You could % %!"]
    ) {
        self.verbs = verbs
        self.things = things
        self.methods = methods
        self.templates = templates
    }

    public func invoke(output: CommandOutput, context: CommandContext) {
        guard let verb = verbs.randomElement(),
            let thing = things.randomElement(),
            let method = methods.randomElement(),
            let template = templates.randomElement() else {
            output.append(errorText: "No verb/thing/method/template available!")
            return
        }
        output.append(template.applyAsTemplate(to: [verb, thing, method]))
    }
}
