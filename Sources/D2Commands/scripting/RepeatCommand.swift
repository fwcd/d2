import D2Utils

fileprivate let argsPattern = try! Regex(from: "(\\d+)\\s*(.*)\\s*")

public class RepeatCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Repeats the input string n times",
        helpText: "Syntax: [n] [string]?",
        requiredPermissionLevel: .basic
    )

	public init() {}

	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard
            let parsedArgs = argsPattern.firstGroups(in: input),
            let times = Int(parsedArgs[1]) else {
            output.append(errorText: info.helpText!)
            return
        }
        let base = parsedArgs[2]
        output.append(String(repeating: base, count: times))
    }
}
