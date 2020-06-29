import Foundation
import D2MessageIO

public class CommandOfTheDayCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Showcases a new command, every day",
        requiredPermissionLevel: .basic
    )
    private let commandPrefix: String

    public init(commandPrefix: String) {
        self.commandPrefix = commandPrefix
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let calendar = Calendar(identifier: .gregorian)
        var hasher = Hasher()
        hasher.combine(calendar.dateComponents([.year, .month, .day], from: Date()))
        let commandEntries = context.registry
            .compactMap { (k, v) in v.asCommand.map { (k, $0) } }
            .filter { (_, c) in c.info.requiredPermissionLevel == .basic }
        let (name, command) = commandEntries[abs(hasher.finalize()) % commandEntries.count]

        output.append(Embed(
            title: ":medal: The Command of the Day: `\(commandPrefix)\(name)`",
            description: command.info.longDescription,
            footer: Embed.Footer(text: "\(command.inputValueType) -> \(command.outputValueType)")
        ))
    }
}
