import Utils

fileprivate let argsPattern = #/(?<count>\d+)\s*(?<base>.*)\s*/#

public class RepeatCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Repeats the input string n times",
        helpText: "Syntax: [n] [string]?",
        requiredPermissionLevel: .basic
    )
    private let maxCount: Int
    private let maxTotalLength: Int

    public init(maxCount: Int = 100, maxTotalLength: Int = 1800) {
        self.maxCount = maxCount
        self.maxTotalLength = maxTotalLength
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard
            let parsedArgs = try? argsPattern.firstMatch(in: input),
            let count = Int(parsedArgs.count) else {
            await output.append(errorText: info.helpText!)
            return
        }
        guard count <= maxCount else {
            await output.append(errorText: "Please enter a count lower than or equal to \(maxCount)")
            return
        }
        let base = String(parsedArgs.base)
        let result = String(repeating: base, count: count)
        guard result.count <= maxTotalLength else {
            await output.append(errorText: "Please make sure that the output string is shorter than (or equal in length to) \(maxTotalLength)")
            return
        }
        await output.append(result)
    }
}
