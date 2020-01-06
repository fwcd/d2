import Logging
import SwiftDiscord
import D2Utils

fileprivate let log = Logger(label: "PointfulCommand")

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
            output.append(error, errorText: "An error occurred while converting to pointful notation")
        }
    }
}
