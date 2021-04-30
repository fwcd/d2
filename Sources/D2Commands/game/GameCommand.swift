import Logging
import D2MessageIO
import D2Permissions
import Utils

fileprivate let log = Logger(label: "D2Commands.GameCommand")
fileprivate let flagRegex = try! Regex(from: "--(\\S+)")
fileprivate let actionMessageRegex = try! Regex(from: "^(\\S+)(?:\\s+(.+))?")

/// Provides a base layer of functionality for a turn-based games.
public class GameCommand<G: Game>: Command {
    public private(set) var info = CommandInfo(
        category: .game,
        presented: true,
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true,
        userOnly: false
    ) // Initialized in init

    private let game: G
    private let defaultActions: [String: (G, ActionParameters<G.State>) throws -> ActionResult<G.State>] = [
        "cancel": { _, _ in ActionResult(cancelsMatch: true, onlyCurrentPlayer: false) },
        "help": { game, _ in ActionResult(text: game.helpText, onlyCurrentPlayer: false) }
    ]
    private let defaultApiActions: Set<String> = ["cancel"]
    private var subcommands: [String: (CommandOutput) throws -> Void] = [:]

    private var matches: [ChannelID: G.State] = [:]
    private var apiEnabled: Bool = false
    private var silent: Bool = false

    public init() {
        game = G.init()
        subcommands = [
            "matches": { [unowned self] in self.matches(output: $0) }
        ]
        info.shortDescription = "Plays \(game.name) against someone"
        info.longDescription = "Lets you create and play \(game.name) matches"
        info.helpText = game.helpText + """


            Generic subcommands (not directly related to \(game.name)):
            \(subcommands.map { "- `\($0.key)`" }.joined(separator: "\n"))
            """
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        let text = input.asText ?? ""
        if let subcommand = subcommands[text] {
            do {
                try subcommand(output)
            } catch {
                output.append(error, errorText: "Error while running subcommand: \(error)")
            }
            return
        }

        guard let channel = context.channel else {
            output.append(errorText: "No channel to play on.")
            return
        }

        guard let mentions = input.asMentions, mentions.count >= 1 else {
            output.append(errorText: "Mention one or more users to play against.")
            return
        }
        guard let author = context.author else {
            output.append(errorText: "Message has no author.")
            return
        }

        let flags = parseFlags(from: text)
        let players = ([author] + mentions).map { gamePlayer(from: $0, context: context) }

        // TODO: Support computer vs. computer matches without spamming the channel
        guard players.count(forWhich: \.isAutomatic) <= 1 else {
            output.append(errorText: "Matches with multiple automatic players are currently not supported!")
            return
        }

        startMatch(between: players, on: channel.id, output: output, flags: flags)
        context.subscribeToChannel()
    }

    private func matches(output: CommandOutput) {
        output.append(.embed(Embed(
            title: ":video_game: Running \(game.name) matches",
            description: matches
                .map { "\($0.key): \($0.value.playersDescription)" }
                .joined(separator: "\n")
                .nilIfEmpty ?? "No matches"
        )))
    }

    private func parseFlags(from input: String) -> Set<String> {
        return Set(flagRegex.allGroups(in: input).map { $0[1] })
    }

    private func sendHandsAsDMs(fromState state: G.State, to output: CommandOutput) {
        let currentPlayers = state.playersOf(role: state.currentRole)

        if game.onlySendHandToCurrentRole && !game.isRealTime && !currentPlayers.isEmpty {
            if let hand = state.hands[state.currentRole] {
                for player in currentPlayers {
                    output.append(hand.asRichValue, to: .dmChannel(player.id))
                }
            }
        } else {
            for (role, hand) in state.hands {
                for player in state.playersOf(role: role) {
                    output.append(hand.asRichValue, to: .dmChannel(player.id))
                }
            }
        }
    }

    func startMatch(between players: [GamePlayer], on channelID: ChannelID, output: CommandOutput, flags: Set<String> = []) {
        do {
            var additionalMsg: RichValue = .none
            if let previousMatch = matches[channelID] {
                additionalMsg = .text("The old match \(previousMatch.playersDescription) has been cancelled in favor of this one")
            }

            var state = try G.State.init(players: players)

            // TODO: This would be an issue if all players are automatic, which is currently forbidden
            if let engine = game.engine {
                do {
                    while state.playersOf(role: state.currentRole).contains(where: \.isAutomatic) {
                        try state.perform(move: engine.pickMove(from: state), by: state.currentRole)
                    }
                } catch {
                    output.append(errorText: "Could not perform initial automatic moves!")
                }
            }

            matches[channelID] = state
            apiEnabled = flags.contains("api")
            silent = flags.contains("silent")

            var encodedBoard: RichValue = .none
            if game.renderFirstBoard {
                encodedBoard = state.board.asRichValue

                if case .embed(_) = encodedBoard {
                    log.warning("Embed-encoded boards are currently not supported by GameCommand")
                }
            }

            output.append(.compound([
                encodedBoard,
                additionalMsg,
                .embed(Embed(
                    title: "New match: \(state.playersDescription)",
                    color: game.themeColor.map { Int($0.rgb) },
                    footer: Embed.Footer(text: "Type 'help' for details!"),
                    fields: [
                        Embed.Field(name: "Game actions", value: listFormat(game.actions.keys), inline: true),
                        Embed.Field(name: "General actions", value: listFormat(defaultActions.keys), inline: true),
                        Embed.Field(name: "Info", value: describeTurn(in: state), inline: false)
                    ]
                ))
            ]))
            sendHandsAsDMs(fromState: state, to: output)
        } catch let GameError.invalidPlayerCount(reason) {
            output.append(errorText: "Invalid player count: \(reason)")
        } catch {
            output.append(error, errorText: "Could not create match")
        }
    }

    private func listFormat<T: Sequence>(_ sequence: T) -> String where T.Element: StringProtocol {
        return sequence.joined(separator: "\n")
    }

    public func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext) {
        guard let author = context.author.map({ gamePlayer(from: $0, context: context) }) else { return }

        if let actionArgs = actionMessageRegex.firstGroups(in: content), let channel = context.channel {
            let continueSubscription = perform(actionArgs[1], withArgs: actionArgs[2], on: channel.id, output: output, author: author)
            if !continueSubscription {
                context.unsubscribeFromChannel()
            }
        }
    }

    private func gamePlayer(from user: User, context: CommandContext) -> GamePlayer {
        GamePlayer(from: user, isAutomatic: user.id == context.client?.me?.id)
    }

    /// Performs a game action if present, otherwise does nothing. Returns whether to continue the subscription.
    /// Automatically performs subsequent computer moves as needed.
    @discardableResult
    private func perform(_ actionKey: String, withArgs args: String, on channelID: ChannelID, output: CommandOutput, author: GamePlayer) -> Bool {
        guard let state = matches[channelID], (author.isUser || game.apiActions.contains(actionKey) || defaultApiActions.contains(actionKey)) else { return true }
        let output = BufferedOutput(output)
        var continueSubscription: Bool = true
        var continueAutomatically: Bool = false

        do {
            let params = ActionParameters(
                args: args,
                state: state,
                apiEnabled: apiEnabled,
                player: author
            )
            guard let actionResult = try game.actions[actionKey]?(params) ?? defaultActions[actionKey]?(game, params) else { return true }

            guard !actionResult.onlyCurrentPlayer
                || game.isRealTime
                || state.rolesOf(player: author).contains(state.currentRole) else {
                output.append(errorText: "It is not your turn, `\(author.username)`")
                return true
            }

            if actionResult.cancelsMatch {
                matches[channelID] = nil
                output.append("Cancelled match: \(state.playersDescription)")
                return false
            }

            if let next = actionResult.nextState {
                // Output next board and user's hands
                var embed: Embed? = nil

                sendHandsAsDMs(fromState: next, to: output)

                if let winner = next.winner {
                    // Game won

                    embed = Embed(
                        title: ":crown: Winner",
                        description: "\(describe(role: winner, in: next)) won the game!"
                    )

                    matches[channelID] = nil
                    continueSubscription = false
                } else if next.isDraw {
                    // Game over due to a draw

                    embed = Embed(
                        title: ":crown: Game Over",
                        description: "The game resulted in a draw!"
                    )

                    matches[channelID] = nil
                    continueSubscription = false
                } else {
                    // Advance the game

                    embed = Embed(
                        description: [
                            actionResult.text,
                            next.handsDescription.map { "Hands: \($0)" },
                            describeTurn(in: next)
                        ].compactMap { $0 }.joined(separator: "\n").nilIfEmpty
                    )

                    matches[channelID] = next
                    continueAutomatically = next.playersOf(role: next.currentRole).contains(where: \.isAutomatic)
                }

                if !silent || !continueSubscription {
                    let encodedBoard: RichValue = next.board.asRichValue
                    output.append(.compound([
                        encodedBoard,
                        .embed(embed),
                        .files(actionResult.files)
                    ]))
                }
            } else if let text = actionResult.text {
                output.append(text)
            }
        } catch GameError.invalidMove(let msg) {
            output.append(errorText: "Invalid move by \(describe(role: state.currentRole, in: state)): \(msg)")
        } catch GameError.ambiguousMove(let msg) {
            output.append(errorText: "Ambiguous move by \(describe(role: state.currentRole, in: state)): \(msg)")
        } catch GameError.incompleteMove(let msg) {
            output.append(errorText: "Ambiguous move by \(describe(role: state.currentRole, in: state)): \(msg)")
        } catch GameError.moveOutOfBounds(let msg) {
            output.append(errorText: "Move by \(describe(role: state.currentRole, in: state)) out of bounds: \(msg)")
        } catch {
            output.append(error, errorText: "Error while attempting move")
        }

        if continueAutomatically {
            return performAutomatically(on: channelID, output: output)
        } else {
            return continueSubscription
        }
    }

    /// Automatically performs the next move. Returns whether to continue the subscription.
    private func performAutomatically(on channelID: ChannelID, output: CommandOutput) -> Bool {
        guard let state = matches[channelID] else { return true }
        guard let engine = game.engine else {
            output.append(errorText: "No engine available for this game to perform moves automatically!")
            return false
        }

        var continueSubscription = true
        var continueAutomatically: Bool = false

        do {
            let move = try engine.pickMove(from: state)
            let next = try state.childState(after: move)
            matches[channelID] = next
            continueAutomatically = next.playersOf(role: next.currentRole).contains(where: \.isAutomatic)

            let encodedBoard: RichValue = next.board.asRichValue
            output.append(.compound([
                encodedBoard,
                .embed(Embed(
                    description: [
                        next.handsDescription.map { "Hands: \($0)" },
                        describeTurn(in: next)
                    ].compactMap { $0 }.joined(separator: "\n").nilIfEmpty
                ))
            ]))
        } catch {
            output.append(error, errorText: "Error while performing move automatically")
            continueSubscription = false
        }

        if continueAutomatically {
            return performAutomatically(on: channelID, output: output)
        } else {
            return continueSubscription
        }
    }

    private func describe(role: G.State.Role, in state: G.State) -> String {
        let players = state.playersOf(role: role)
        if game.hasPrettyRoles {
            return "\(role.asRichValue.asText ?? "") aka. \(players.map { "`\($0.username)`" }.englishEnumerated())"
        } else {
            return players.map { "`\($0.username)`" }.englishEnumerated()
        }
    }

    private func describeTurn(in state: G.State) -> String {
        if game.isRealTime {
            return "Next turn!"
        } else {
            let roleDescription = game.hasPrettyRoles
                ? "\(describe(role: state.currentRole, in: state))'s"
                : state.playersOf(role: state.currentRole).map { "`\($0.username)`'s" }.englishEnumerated()
            return "It is now \(roleDescription) turn."
        }
    }
}
