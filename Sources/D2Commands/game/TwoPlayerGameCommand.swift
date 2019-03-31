import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let moveMessageRegex = try! Regex(from: "move\\s+(.+)")
fileprivate let cancelMessageRegex = try! Regex(from: "cancel\\s+(\\S+)")

/**
 * Provides a base layer of functionality for a turn-based 
 * two-player game.
 */
public class TwoPlayerGameCommand<State: GameState>: StringCommand {
	public let requiredPermissionLevel = PermissionLevel.basic
	public let subscribesToNextMessages = true
	public let name: String
	public var description: String { return "Plays \(name) against someone" }
	
	private var currentState: State? = nil
	
	public init(withName name: String) {
		self.name = name
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard currentState == nil else {
			output.append("Wait for the current match to finish before creating a new one.")
			return
		}
		
		guard let opponent = context.message.mentions.first else {
			output.append("Mention an opponent to play against.")
			return
		}
		
		startMatch(between: GamePlayer(from: context.author), and: GamePlayer(from: opponent), output: output)
	}
	
	private func sendHandsAsDMs(fromState state: State, to output: CommandOutput) {
		for (role, hand) in state.hands {
			if let player = state.playerOf(role: role) {
				output.append(hand.discordMessageEncoded, to: .userChannel(player.id))
			}
		}
	}
	
	func startMatch(between firstPlayer: GamePlayer, and secondPlayer: GamePlayer, output: CommandOutput) {
		let state = State.init(firstPlayer: firstPlayer, secondPlayer: secondPlayer)
		
		currentState = state
		output.append("Playing new match: \(state)\n\(state.board.discordStringEncoded)\nType `move [...]` to begin!")
		sendHandsAsDMs(fromState: state, to: output)
	}
	
	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		let author = GamePlayer(from: context.author)
		
		if let moveArgs = moveMessageRegex.firstGroups(in: content) {
			return move(withArgs: Array(moveArgs.dropFirst()), output: output, author: author)
		} else if let cancelArgs = cancelMessageRegex.firstGroups(in: content) {
			return cancel(withArgs: Array(cancelArgs.dropFirst()), output: output, author: author)
		}
		
		return .continueSubscription
	}
	
	@discardableResult
	/** Performs a move. The arguments are zero-indexed. */
	func move(withArgs moveArgs: [String], output: CommandOutput, author: GamePlayer) -> CommandSubscriptionAction {
		guard let state = currentState else { return .continueSubscription }
		let roles = state.rolesOf(player: author)
		
		guard roles.contains(state.currentRole) else {
			print("Current player: \(state.currentRole), roles: \(roles)")
			output.append("It is not your turn, `\(author.username)`")
			return .continueSubscription
		}
		
		do {
			let next = try state.childState(after: try State.Move.init(fromString: moveArgs[0]))
			output.append(next.board.discordMessageEncoded)
			sendHandsAsDMs(fromState: next, to: output)
			
			if let winner = next.board.winner {
				// Game won
				
				var embed = DiscordEmbed()
				embed.title = ":crown: Winner"
				embed.description = "\(winner.discordStringEncoded)\(state.playerOf(role: winner).map { " aka. `\($0.username)`" } ?? "") won the game!"
				
				output.append(embed)
				currentState = nil
				return .cancelSubscription
			} else if next.board.isDraw {
				// Game over due to a draw
				
				var embed = DiscordEmbed()
				embed.title = ":crown: Game Over"
				embed.description = "The game resulted in a draw!"
				
				output.append(embed)
				currentState = nil
				return .cancelSubscription
			} else {
				// Advance the game
				
				currentState = next
			}
		} catch GameError.invalidMove(let msg) {
			output.append("Invalid move by \(state.currentRole.discordStringEncoded): \(msg)")
		} catch {
			output.append("Error while attempting move")
			print(error)
		}
		
		return .continueSubscription
	}
	
	@discardableResult
	/** Cancels the current match. The arguments are zero-indexed. */
	func cancel(withArgs cancelArgs: [String], output: CommandOutput, author: GamePlayer) -> CommandSubscriptionAction {
		guard let state = currentState else { return .continueSubscription }
		let arg = cancelArgs[0]
		
		switch arg {
			case "match":
				currentState = nil
				output.append("Cancelled match: \(state)")
				return .cancelSubscription
			default:
				output.append("Sorry, I do not know how to cancel `\(arg)`")
		}
		return .continueSubscription
	}
}
