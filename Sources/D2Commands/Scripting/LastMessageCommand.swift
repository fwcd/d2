import Utils
import D2Permissions
import Logging

fileprivate let log = Logger(label: "D2Commands.LastMessageCommand")

fileprivate enum LastMessageError: Error {
    case noLastMessage
}

public class LastMessageCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Fetches the last message",
        longDescription: "Retrieves and outputs the last message",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .none
    public let outputValueType: RichValueType = .any

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        do {
            let messages = try await context.sink?.getMessages(for: context.channel!.id, limit: 2).get()
            guard let message = messages?[safely: 1] else {
                throw LastMessageError.noLastMessage
            }
            let value = await MessageParser().parse(message: message, clientName: context.sink?.name, guild: context.guild)
            await output.append(value)
        } catch {
            await output.append(error, errorText: "Could not find last message.")
        }
    }
}
