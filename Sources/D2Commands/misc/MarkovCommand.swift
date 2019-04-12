import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let flagPattern = try! Regex(from: "--(\\S+)")

public class MarkovCommand: StringCommand {
	public let description = "Generates a natural language response using a Markov chain"
	public let helpText = "Syntax: markov [--all]? [@user]?"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let order = 3
	private let maxWords = 60
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let channelId = context.channel?.id else {
			output.append("Could not figure out the channel we are on")
			return
		}
		guard let client = context.client else {
			output.append("MarkovCommand can not be invoked without a client")
			return
		}
		
		let flags = Set<String>(flagPattern.allGroups(in: input).map { $0[1] })
		let mentioned = context.message.mentions.first
		let channels: Set<ChannelID>
		
		if flags.contains("all"), let guild = context.guild {
			channels = Set(guild.channels.keys)
		} else {
			channels = [channelId]
		}
		
		var queriedChannels = 0
		var allMessages = [DiscordMessage]()
		
		for queryChannel in channels {
			client.getMessages(for: queryChannel, selection: nil, limit: 80) { messages, _ in
				allMessages.append(contentsOf: messages)
				queriedChannels += 1
				
				if channels.count == queriedChannels {
					// Resolved all channels, generate Markov text now
					
					let words = allMessages
						.filter { msg in mentioned.map { msg.author.id == $0.id } ?? true }
						.map { $0.content }
						.flatMap { $0.split(separator: " ") }
					guard let startWord = words.randomElement() else {
						output.append("Did not find any words in this channel")
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
