public class RemoveAllMIOCommandsCommand: StringCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Removes all global MIO commands",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let client = context.client else {
            output.append(errorText: "No client present")
            return
        }

        client.getMIOCommands().listen {
            do {
                let mioCommands = try $0.get()

                for mioCommand in mioCommands {
                    client.deleteMIOCommand(mioCommand.id)
                }

                output.append("Deleted \(mioCommands.count) MIO commands")
            } catch {
                output.append(error, errorText: "Could not fetch MIO commands")
            }
        }
    }
}
