import SwiftDiscord
import D2Utils

public class PointfulCommand: StringCommand {
    public let info = CommandInfo(
        category: .haskell,
        shortDescription: "Pointful notation converter",
        longDescription: "Converts a Haskell expression into pointful notation",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .code
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let pointful = try Shell().outputSync(for: "pointful", args: [input])
            output.append(.code(pointful ?? "No results", language: "haskell"))
        } catch {
            print(error)
            output.append("An error occurred while converting to pointful notation")
        }
    }
}
