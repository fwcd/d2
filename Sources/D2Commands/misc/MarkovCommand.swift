import D2MessageIO
import D2Permissions
import D2Utils

fileprivate let flagPattern = try! Regex(from: "--(\\S+)")
fileprivate let pingPattern = try! Regex(from: "<@&?.+?>")

// TODO: Use Arg API

public class MarkovCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Generates a natural language response using a Markov chain",
		longDescription: "Uses a Markov chain with data from the current channel to generate a human-like response",
		helpText: "Syntax: markov [--all]? [--noping]? [@user]?",
		requiredPermissionLevel: .admin // TODO: Admin-only until guild member permissions are fixed, see invoke method below
	)
	private let order = 2
	private let maxWords = 60
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let channelId = context.channel?.id else {
			output.append(errorText: "Could not figure out the channel we are on")
			return
		}
		guard let client = context.client else {
			output.append(errorText: "MarkovCommand can not be invoked without a client")
			return
		}
		
		let flags = Set<String>(flagPattern.allGroups(in: input).map { $0[1] })
		let mentioned = context.message.mentions.first
		
		if flags.contains("all"), let guild = context.guild {
			guard let me = client.me.flatMap({ guild.members[$0.id] }) else {
				output.append("Could not fetch guild member for myself")
				return
			}

			let channels = Set(guild.channels
				// TODO: Add an API to query for member permissions to MessageIO
				// .filter { $0.value.canMember(me, .readMessages) }
				.map { $0.key })
			self.markovGenerate(using: channels, output: output, flags: flags, mentioned: mentioned, client: client)
		} else {
			markovGenerate(using: [channelId], output: output, flags: flags, mentioned: mentioned, client: client)
		}
	}
	
	private func markovGenerate(using channels: Set<ChannelID>, output: CommandOutput, flags: Set<String>, mentioned: User?, client: MessageClient) {
		var queriedChannels = 0
		var allMessages = [Message]()
		
		for queryChannel in channels {
			client.getMessages(for: queryChannel, limit: 80) { messages, _ in
				allMessages.append(contentsOf: messages)
				queriedChannels += 1
				
				if channels.count == queriedChannels {
					// Resolved all channels, generate Markov text now
					
					var words = allMessages
						.filter { msg in msg.author.map { author in mentioned.map { author.id == $0.id } ?? !author.bot } ?? false }
						.map { $0.content }
						.flatMap { $0.split(separator: " ") }
					
					if flags.contains("noping") {
						words = words.map { pingPattern.replace(in: String($0), with: ":ping_pong:")[...] }
					}
					
					guard let startWord = words.randomElement() else {
						output.append(errorText: "Did not find any words in this channel")
						return
					}
					
					let matrix = MarkovTransitionMatrix(fromElements: words, order: self.order)
					let stateMachine = MarkovStateMachine(matrix: matrix, startValue: startWord, maxLength: self.maxWords)
					var result = [Substring]()
					
					for word in stateMachine {
						result.append(word)
					}
					
					output.append(result.joined(separator: " "))
				}
			}
		}
	}
}
