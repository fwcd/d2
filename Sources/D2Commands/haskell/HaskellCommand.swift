import SwiftDiscord
import D2Utils

fileprivate let importedModules = ["Prelude"]

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
            let moduleArgs = importedModules.flatMap { ["-m", $0] }
            let value = try Shell().outputSync(for: "mueval", args: ["-n", "-e", input, "-t", String(timeout)] + moduleArgs)
            output.append(.code(value ?? "No output", language: "haskell"))
        } catch {
            print(error)
            output.append("Could not evaluate expression.")
        }
    }
}
