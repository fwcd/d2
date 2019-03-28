import SwiftDiscord
import D2Utils

fileprivate let moveMessageRegex = try! Regex(from: "move\\s+(.+)")
fileprivate let cancelMessageRegex = try! Regex(from: "cancel\\s+(\\S+)")

/**
 * Provides a base layer of functionality for a turn-based 
 * two-player game.
 */
class TwoPlayerGameCommand<Match: GameMatch>: StringCommand {
	let requiredPermissionLevel = PermissionLevel.basic
	let subscribesToNextMessages = true
	let name: String
	var description: String { return "Plays \(name) against someone" }
	
	var currentMatch: Match? = nil
	
	init(withName name: String) {
		self.name = name
	}
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard currentMatch == nil else {
			output.append("Wait for the current match to finish before creating a new one.")
			return
		}
		
		guard let opponent = context.message.mentions.first else {
			output.append("Mention an opponent to play against.")
			return
		}
		
		let playerX = context.author
		let playerO = opponent
		let match = Match.init(firstPlayer: playerX, secondPlayer: playerO)
		
		currentMatch = match
		output.append("Playing new match: \(match)\n\(match.board.discordEncoded)\nType `move [...]` to begin!")
	}
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		if let match = currentMatch {
			if let moveArgs = moveMessageRegex.firstGroups(in: content) {
				return handleMoveMessage(withMatch: match, moveArgs: moveArgs, output: output, context: context)
			} else if let cancelArgs = cancelMessageRegex.firstGroups(in: content) {
				return handleCancelMessage(withMatch: match, cancelArgs: cancelArgs, output: output, context: context)
			}
		}
		return .continueSubscription
	}
	
	func handleMoveMessage(withMatch match: Match, moveArgs: [String], output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		let roles = match.rolesOf(player: context.author)
		
		guard roles.contains(match.currentRole) else {
			print("Current player: \(match.currentRole), roles: \(roles)")
			output.append("It is not your turn, `\(context.author.username)`")
			return .continueSubscription
		}
		
		do {
			try match.perform(move: try Match.Move.init(fromString: moveArgs[1]))
			output.append(match.board.discordEncoded)
			
			if let winner = match.board.winner {
				// Game won
				
				var embed = DiscordEmbed()
				embed.title = ":crown: Winner"
				embed.description = "\(winner.discordEncoded)\(match.playerOf(role: winner).map { " aka. `\($0.username)`" } ?? "") won the game!"
				
				output.append(embed)
				currentMatch = nil
				return .cancelSubscription
			} else if match.board.isDraw {
				// Game over due to a draw
				
				var embed = DiscordEmbed()
				embed.title = ":crown: Game Over"
				embed.description = "The game resulted in a draw!"
				
				output.append(embed)
				currentMatch = nil
				return .cancelSubscription
			}
		} catch GameError.invalidMove(let msg) {
			output.append("Invalid move by \(match.currentRole.discordEncoded): \(msg)")
		} catch {
			output.append("Error while attempting move")
			print(error)
		}
		
		return .continueSubscription
	}
	
	func handleCancelMessage(withMatch match: Match, cancelArgs: [String], output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		let arg = cancelArgs[1]
		switch arg {
			case "match":
				currentMatch = nil
				output.append("Cancelled match: \(match)")
				return .cancelSubscription
			default:
				output.append("Sorry, I do not know how to cancel `\(arg)`")
		}
		return .continueSubscription
	}
}
