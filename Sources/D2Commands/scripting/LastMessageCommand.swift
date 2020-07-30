import D2Utils
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
		requiredPermissionLevel: .vip
	)
	public let inputValueType: RichValueType = .none
	public let outputValueType: RichValueType = .any

	public init() {}

	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		context.client?.getMessages(for: context.channel!.id, limit: 2)
            .then { Promise(Result.from($0[safely: 1], errorIfNil: LastMessageError.noLastMessage)) }
            .then { MessageParser().parse(message: $0, clientName: context.client?.name, guild: context.guild) }
            .listen {
                do {
                    output.append(try $0.get())
                } catch {
                    output.append(error, errorText: "Could not find last message.")
                }
		}
	}
}
