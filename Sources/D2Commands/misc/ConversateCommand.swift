public class ConversateCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Uses a Markov chain to 'conversate' with the user",
        subscribesToNextMessages: true,
        userOnly: false
    )
    private let messageDB: MessageDatabase
    
    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        context.subscribeToChannel()
    }
    
    public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {
        if content == "stop" {
            context.unsubscribeFromChannel()
        } else {
            guard !content.isEmpty else { return }
            do {
                let results = try messageDB.followUps(to: String(content.split(separator: " ").last!))
                output.append("Followups:\n```\n\(results)\n```")
            } catch {
                output.append(error, errorText: "Could not query message DB")
            }
        }
    }
}
