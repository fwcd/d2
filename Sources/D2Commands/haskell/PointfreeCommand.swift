import SwiftDiscord
import D2Utils

public class PointfreeCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
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
            print(error)
            output.append("An error occurred while converting to pointfree notation")
        }
    }
}
