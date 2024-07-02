public class RemoveAllMIOCommandsCommand: VoidCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Removes all global MIO commands",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        guard let sink = context.sink else {
            await output.append(errorText: "No client present")
            return
        }

        do {
            let mioCommands = try await sink.getMIOCommands()

            for mioCommand in mioCommands {
                try await sink.deleteMIOCommand(mioCommand.id)
            }

            await output.append("Deleted \(mioCommands.count) MIO commands")
        } catch {
            await output.append(error, errorText: "Could not delete MIO commands")
        }
    }
}
