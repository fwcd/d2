import D2MessageIO
import PrologInterpreter
import PrologSyntax

public class PrologCommand: Command {
    public var info = CommandInfo(
        category: .programming,
        shortDescription: "Interprets Prolog",
        longDescription: "Parses Prolog rules and performs queries on them",
        requiredPermissionLevel: .admin // TODO: Place a timeout on the interpreter that breaks a
                                        //       potentially non-terminating resolution (i.e. an infinite recursion)
                                        //       without possibly crashing the application (e.g. due to a stack overflow)
    )
    private var subcommands: [String: (RichValue, CommandOutput) async -> Void] = [:]
    private var loadedProgram: Program? = nil

    public init() {
        subcommands = [
            "load": { [unowned self] input, output in
                guard let rawProgram = input.asCode ?? input.asText else {
                    await output.append("Please enter a Prolog program (a collection of rules)!")
                    return
                }
                guard let program = Program.parser.parseValue(from: rawProgram) else {
                    await output.append("Could not parse program.")
                    return
                }
                self.loadedProgram = program
            },
            "prove": { [unowned self] input, output in
                guard let program = self.loadedProgram else {
                    await output.append("Please load a program first!")
                    return
                }
                guard let rawGoal = input.asCode ?? input.asText else {
                    await output.append("Please enter a Prolog goal (a collection of provable statements)!")
                    return
                }
                guard let goal = Goal.parser.parseValue(from: rawGoal) else {
                    await output.append("Could not parse goal.")
                    return
                }
                let solutions = DepthFirstSearch().traverse(tree: SLDTree(resolving: goal, in: program)).map { $0.restricted(to: goal.allVariableNames) }
                await output.append(.code("\(solutions)", language: "prolog"))
            }
        ]
        info.helpText = """
            Syntax: [subcommand] [subcommand args]?

            Subcommands: \(subcommands.keys.joined(separator: ", "))
            """
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let subcommandName = input.asText?.split(separator: " ").first else {
            await output.append(errorText: info.helpText!)
            return
        }
        guard let subcommand = subcommands[String(subcommandName)] else {
            await output.append(errorText: "Unknown subcommand `\(subcommandName)`, try one of these: `\(subcommands.keys.joined(separator: ", "))`")
            return
        }
        let subcommandInput = RichValue.of(values: input.values.map {
            guard case let .text(t) = $0 else { return $0 }
            return .text(t.split(separator: " ").dropFirst().joined(separator: " "))
        })
        await subcommand(subcommandInput, output)
    }
}
