import D2MessageIO
import D2Permissions
import Utils

fileprivate let rawRangePattern = "\\d+\\.\\.[\\.<]\\d+"

// Matches the arguments, capturing the range
fileprivate let inputPattern = try! LegacyRegex(from: "^(\(rawRangePattern))")

public class ForCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Iterates over a range",
        longDescription: "Iterates over a range and outputs the running index at each iteration",
        requiredPermissionLevel: .admin
    )
    public let outputValueType: RichValueType = .text
    private let timer: RepeatingTimer
    private let maxRangeLength: Int

    public init(intervalSeconds: Int = 1, maxRangeLength: Int = 64) {
        timer = RepeatingTimer(interval: .seconds(intervalSeconds))
        self.maxRangeLength = maxRangeLength
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard !timer.isRunning else {
            output.append(errorText: "Cannot run multiple `for`-loops concurrently")
            return
        }

        guard let parsedArgs = inputPattern.firstGroups(in: input) else {
            output.append(errorText: "Syntax error: For arguments need to match `[number](...|..<)[number]`")
            return
        }

        let rawRange = parsedArgs[1]

        if let range: LowBoundedIntRange = parseIntRange(from: rawRange) ?? parseClosedIntRange(from: rawRange) {
            if range.count <= maxRangeLength {
                timer.schedule(nTimes: range.count) { i, _ in
                    output.append(String(range.lowerBound + i))
                }
            } else {
                output.append(errorText: "Your range is too long!")
            }
        }
    }
}
