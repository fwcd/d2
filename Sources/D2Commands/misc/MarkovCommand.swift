import SwiftDiscord
import D2Permissions

public class MarkovCommand: StringCommand {
	public let description = "Generates a natural language response using a Markov chain"
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
		let mentioned = context.message.mentions.first
		
		client.getMessages(for: channelId, selection: nil, limit: 80) { messages, _ in
			let words = messages
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
