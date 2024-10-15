import Utils

public class RepeatCommand: RegexCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Repeats the input string n times",
        helpText: "Syntax: [n] [string]?",
        requiredPermissionLevel: .basic
    )

    public let inputPattern = #/(?<count>\d+)\s*(?<base>.*)\s*/#

    private let maxCount: Int
    private let maxTotalLength: Int

    public init(maxCount: Int = 100, maxTotalLength: Int = 1800) {
        self.maxCount = maxCount
        self.maxTotalLength = maxTotalLength
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        guard let count = Int(input.count) else {
            await output.append(errorText: info.helpText!)
            return
        }
        guard count <= maxCount else {
            await output.append(errorText: "Please enter a count lower than or equal to \(maxCount)")
            return
        }
        let base = String(input.base)
        let result = String(repeating: base, count: count)
        guard result.count <= maxTotalLength else {
            await output.append(errorText: "Please make sure that the output string is shorter than (or equal in length to) \(maxTotalLength)")
            return
        }
        await output.append(result)
    }
}
