import D2MessageIO
import D2Permissions
import D2Utils

public class GrepCommand: ArgCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Filters using a regex",
        longDescription: "Filters and outputs lines that match a given regular expression",
        requiredPermissionLevel: .vip
    )
    public let outputValueType: RichValueType = .text
    public let argPattern = ArgPair(
        patternWithLeft: ArgValue(name: "regex", examples: ["\\d+", "(?:test|demo)*"]),
        right: ArgRepeat(patternWithValue: ArgValue(name: "line", examples: ["something"]))
    )

    public init() {}

    public func invoke(with input: Args, output: CommandOutput, context: CommandContext) {
        do {
            let regex = try Regex(from: input.left.value)
            var result = ""

            for line in input.right.values.map({ $0.value }) {
                if regex.matchCount(in: line) > 0 {
                    result += line + "\n"
                }
            }

            if result.isEmpty {
                output.append(errorText: "Grep result is empty!")
            } else {
                output.append(result)
            }
        } catch {
            output.append(error, errorText: "Regex syntax error: \(error)")
        }
    }
}
