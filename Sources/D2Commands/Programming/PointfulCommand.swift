import Logging
import D2MessageIO
import Utils

fileprivate let log = Logger(label: "D2Commands.PointfulCommand")

public class PointfulCommand: StringCommand {
    public let info = CommandInfo(
        category: .programming,
        shortDescription: "Pointful notation converter",
        longDescription: "Converts a Haskell expression into pointful notation",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .code

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) async {
        do {
            let pointful = try await Shell().utf8(for: "pointful", args: [input]).get()
            await output.append(.code(pointful ?? "No results", language: "haskell"))
        } catch {
            await output.append(error, errorText: "An error occurred while converting to pointful notation")
        }
    }
}
