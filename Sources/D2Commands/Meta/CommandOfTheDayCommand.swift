import Foundation
import D2MessageIO

public class CommandOfTheDayCommand: VoidCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Showcases a new command, every day",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let commandPrefix: String

    public init(commandPrefix: String) {
        self.commandPrefix = commandPrefix
    }

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        let calendar = Calendar(identifier: .gregorian)
        var hasher = Hasher()
        hasher.combine(calendar.dateComponents([.year, .month, .day], from: Date()))
        let commandEntries = context.registry
            .entries
            .compactMap { (k, v) in v.asCommand.map { (k, $0) } }
            .filter { (_, c) in c.info.requiredPermissionLevel == .basic }
        let (name, command) = commandEntries[abs(hasher.finalize()) % commandEntries.count]

        await output.append(Embed(
            title: ":medal: The Command of the Day: `\(commandPrefix)\(name)`",
            description: command.info.longDescription,
            footer: "\(command.inputValueType) -> \(command.outputValueType)"
        ))
    }
}
