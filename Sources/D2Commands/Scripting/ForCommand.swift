import D2MessageIO
import D2Permissions
import Utils

// Matches the arguments, capturing the range
fileprivate let inputPattern = #/^(?<range>\d+\.\.[\.<]\d+)/#

public class ForCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Iterates over a range",
        longDescription: "Iterates over a range and outputs the running index at each iteration",
        requiredPermissionLevel: .admin
    )
    public let outputValueType: RichValueType = .text
    private let intervalSeconds: Int
    private let maxRangeLength: Int

    public init(intervalSeconds: Int = 1, maxRangeLength: Int = 64) {
        self.intervalSeconds = intervalSeconds
        self.maxRangeLength = maxRangeLength
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsedArgs = try? inputPattern.firstMatch(in: input) else {
            await output.append(errorText: "Syntax error: For arguments need to match `[number](...|..<)[number]`")
            return
        }

        let rawRange = String(parsedArgs.output.range)

        if let range: any LowBoundedIntRange = parseIntRange(from: rawRange) ?? parseClosedIntRange(from: rawRange) {
            if range.count <= maxRangeLength {
                do {
                    for i in range {
                        await output.append(String(i))
                        try await Task.sleep(for: .seconds(intervalSeconds))
                    }
                } catch {
                    await output.append(error, errorText: "Error while sleeping")
                }
            } else {
                await output.append(errorText: "Your range is too long!")
            }
        }
    }
}
