import D2Utils

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
        guard context.author?.id != context.client?.me?.id else { return }
        if content == "stop" {
            context.unsubscribeFromChannel()
            output.append("Unsubscribed from this channel.")
        } else {
            do {
                guard let last = content
                    .split(separator: " ")
                    .last
                    .map({ String($0) })?.nilIfEmpty else { return }
                let followUps = try messageDB.followUps(to: last)
                
                if !followUps.isEmpty {
                    let candidates = followUps.map { ($0.1, matchingSuffixLength($0.0, content)) }
                    let distribution = CustomDiscreteDistribution(normalizing: candidates)
                    output.append(distribution.sample().cleaningMentions(with: context.guild))
                }
            } catch {
                output.append(error, errorText: "Could not query message DB")
            }
        }
    }
    
    private func matchingSuffixLength(_ lhs: String, _ rhs: String) -> Int {
        var i = 0
        var iterator = zip(lhs.reversed(), rhs.reversed()).makeIterator()
        while let (l, r) = iterator.next(), l == r {
            i += 1
        }
        return i
    }
}
