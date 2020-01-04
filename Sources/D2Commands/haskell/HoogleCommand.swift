import SwiftDiscord
import Logging
import D2Utils

fileprivate let log = Logger(label: "HoogleCommand")

public class HoogleCommand: StringCommand {
    public let info = CommandInfo(
        category: .haskell,
        shortDescription: "Hoogles a type signature",
        longDescription: "Searches for a function matching a type signature using the Hoogle search engine",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .code
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let results = try Shell().outputSync(for: "hoogle", args: [input])
            output.append(.code(results ?? "No results", language: "haskell"))
        } catch {
            log.warning("\(error)")
            output.append("An error occurred while hoogling")
        }
    }
}
