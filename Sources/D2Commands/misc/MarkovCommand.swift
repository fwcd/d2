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
		requiredPermissionLevel: .basic
	)
	private let messageDB: MessageDatabase
	private let maxWords = 60
	
	public init(messageDB: MessageDatabase) {
		self.messageDB = messageDB
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let channelId = context.channel?.id else {
			output.append(errorText: "Could not figure out the channel we are on")
			return
		}
		guard let guildId = context.guild?.id else {
			output.append(errorText: "Could not figure out the message's guild")
			return
		}
		
		// TODO: Filter guild ID in messages
		
		let flags = Set<String>(flagPattern.allGroups(in: input).map { $0[1] })
		
		// TODO: Re-implement noping

		// if flags.contains("noping") {
		// 	words = words.map { pingPattern.replace(in: String($0), with: ":ping_pong:")[...] }
		// }

		do {
			// TODO: Use proper initial distribution without sacrificing performance
			let sampleMessage = try messageDB.randomMessage()
			let initialState = try [sampleMessage.content.split(separator: " ").map { String($0) }.first?.nilIfEmpty ?? messageDB.randomMarkovWord()] 
			let stateMachine = MarkovStateMachine(predictor: messageDB, initialState: initialState, maxLength: self.maxWords)
			var result = [String]()
			
			for word in stateMachine {
				result.append(word)
			}
			
			output.append(result.joined(separator: " "))
		} catch {
			output.append(error, errorText: "Could not generate Markov text")
		}
	}
}
