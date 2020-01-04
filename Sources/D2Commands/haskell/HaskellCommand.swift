import Logging
import SwiftDiscord
import D2Utils

fileprivate let log = Logger(label: "HaskellCommand")

public class HaskellCommand: StringCommand {
    public let info = CommandInfo(
        category: .haskell,
        shortDescription: "Evaluates a Haskell expression",
        longDescription: "Computes the result of a (pure) Haskell expression using Mueval",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .code
    private let timeout: Int = 4
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let value = try Shell().outputSync(for: "mueval", args: ["-e", input, "-t", String(timeout)])
            output.append(.code(value ?? "No output", language: "haskell"))
        } catch {
            log.warning("\(error)")
            output.append("Could not evaluate expression.")
        }
    }
}
