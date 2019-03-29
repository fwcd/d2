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
	
	init(withName name: String) {
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
		
		let playerX = context.author
		let playerO = opponent
		let state = State.init(firstPlayer: playerX, secondPlayer: playerO)
		
		currentState = state
		output.append("Playing new match: \(state)\n\(state.board.discordStringEncoded)\nType `move [...]` to begin!")
	}
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		if let state = currentState {
			if let moveArgs = moveMessageRegex.firstGroups(in: content) {
				return handleMoveMessage(withState: state, moveArgs: moveArgs, output: output, context: context)
			} else if let cancelArgs = cancelMessageRegex.firstGroups(in: content) {
				return handleCancelMessage(withState: state, cancelArgs: cancelArgs, output: output, context: context)
			}
		}
		return .continueSubscription
	}
	
	func handleMoveMessage(withState state: State, moveArgs: [String], output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		let roles = state.rolesOf(player: context.author)
		
		guard roles.contains(state.currentRole) else {
			print("Current player: \(state.currentRole), roles: \(roles)")
			output.append("It is not your turn, `\(context.author.username)`")
			return .continueSubscription
		}
		
		do {
			let next = try state.childState(after: try State.Move.init(fromString: moveArgs[1]))
			output.append(next.board.discordMessageEncoded)
			
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
	
	func handleCancelMessage(withState state: State, cancelArgs: [String], output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		let arg = cancelArgs[1]
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
