public class RemoveAllMIOCommandsCommand: VoidCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Removes all global MIO commands",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) {
        guard let sink = context.sink else {
            output.append(errorText: "No client present")
            return
        }

        sink.getMIOCommands().listen {
            do {
                let mioCommands = try $0.get()

                for mioCommand in mioCommands {
                    sink.deleteMIOCommand(mioCommand.id)
                }

                output.append("Deleted \(mioCommands.count) MIO commands")
            } catch {
                output.append(error, errorText: "Could not fetch MIO commands")
            }
        }
    }
}
