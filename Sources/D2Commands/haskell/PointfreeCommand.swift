import Logging
import SwiftDiscord
import D2Utils

fileprivate let log = Logger(label: "PointfreeCommand")

public class PointfreeCommand: StringCommand {
    public let info = CommandInfo(
        category: .haskell,
        shortDescription: "Pointfree notation converter",
        longDescription: "Converts a Haskell expression into pointfree notation",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .code
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let pointfree = try Shell().outputSync(for: "pointfree", args: [input])
            output.append(.code(pointfree ?? "No results", language: "haskell"))
        } catch {
            log.warning("\(error)")
            output.append("An error occurred while converting to pointfree notation")
        }
    }
}
