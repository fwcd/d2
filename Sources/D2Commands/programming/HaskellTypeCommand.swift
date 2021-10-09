import Logging
import D2MessageIO
import Utils

fileprivate let log = Logger(label: "D2Commands.HaskellTypeCommand")

public class HaskellTypeCommand: StringCommand {
    public let info = CommandInfo(
        category: .programming,
        shortDescription: "Evaluates a Haskell expression",
        longDescription: "Computes the result of a (pure) Haskell expression using Mueval",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .code
    private let timeout: Int = 4

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            let lines = try Array((Shell().utf8Sync(for: "mueval", args: ["-iTe", input, "-t", String(timeout)]) ?? "").split(separator: "\n"))
            guard lines.count >= 2 else {
                log.error("Invalid mueval output: \(lines)")
                output.append(errorText: "Invalid mueval output")
                return
            }
            output.append(.code("\(lines[0]) :: \(lines[1])", language: "haskell"))
        } catch {
            output.append(error, errorText: "Could not fetch inferred expression type.")
        }
    }
}
