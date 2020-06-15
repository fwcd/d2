public class IAmBoredCommand: StringCommand {
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
        verbs: [String] = ["solve", "play", "build", "compose", "draw", "write", "fix", "rap", "sing", "catch", "open", "press", "sleep on", "eat"],
        things: [String] = ["a guitar", "a new game", "a song", "a fish", "a button", "a program", "a box", "a crossword puzzle"],
        methods: [String] = ["a pencil", "a keyboard", "your finger", "your imagination", "a friend", "a wrench", "your hand", "a computer", "your voice", "a fishing rod", "a spoon"],
        templates: [String] = ["Why don't you % % with %?", "Try to % % with %!", "You could % % with a %!", "You could % %!"]
    ) {
        self.verbs = verbs
        self.things = things
        self.methods = methods
        self.templates = templates
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let verb = verbs.randomElement(),
            let thing = things.randomElement(),
            let method = methods.randomElement(),
            let template = templates.randomElement() else {
            output.append(errorText: "No verb/thing/method/template available!")
            return
        }
        output.append(apply(template: template, to: [verb, thing, method]))
    }

    private func apply(template: String, to args: [String]) -> String {
        var result = ""
        var argIterator = args.makeIterator()
        for c in template {
            if c == "%" {
                guard let arg = argIterator.next() else { fatalError("Provided too few args to apply(template:to:)!") }
                result += arg
            } else {
                result.append(c)
            }
        }
        return result
    }
}
