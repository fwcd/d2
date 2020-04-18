public class ConversateCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Uses a Markov chain to 'conversate' with the user",
        helpText: "Invoke without argument, then send any message. Type 'stop' to stop the bot from replying.",
        subscribesToNextMessages: true,
        userOnly: false
    )
    private let messageDB: MessageDatabase
	private let maxWords = 60
    
    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        context.subscribeToChannel()
        output.append("Subscribed to this channel. Type anything to talk to me.")
    }
    
    public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {
        if content == "stop" {
            context.unsubscribeFromChannel()
            output.append("Unsubscribed from this channel.")
        } else {
            guard let last = content.split(separator: " ").last.map({ String($0) })?.nilIfEmpty else { return }
            do {
                let initialWord = try messageDB.followUps(to: last).first?.split(separator: " ").first.map { String($0) }?.nilIfEmpty ?? messageDB.randomMarkovWord()
                let stateMachine = MarkovStateMachine(predictor: messageDB, initialState: [initialWord], maxLength: self.maxWords)
                var result = [String]()
                
                for word in stateMachine {
                    result.append(word)
                }
                
                output.append(result.joined(separator: " ").nilIfEmpty ?? ":shrug: No results")
            } catch {
                output.append(error, errorText: "Could not query message DB")
            }
        }
    }
}
