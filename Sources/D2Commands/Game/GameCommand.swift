import Logging
import D2MessageIO
import D2Permissions
import Utils

fileprivate let log = Logger(label: "D2Commands.GameCommand")
nonisolated(unsafe) private let flagRegex = #/--(\S+)/#
nonisolated(unsafe) private let actionMessageRegex = #/^(\S+)(?:\s+(.+))?/#

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
    private var subcommands: [String: (CommandOutput) async throws -> Void] = [:]

    private var matches: [ChannelID: G.State] = [:]
    private var apiEnabled: Bool = false
    private var silent: Bool = false

    public init() {
        game = G.init()
        subcommands = [
            "matches": { [unowned self] in await self.matches(output: $0) }
        ]
        info.shortDescription = "Plays \(game.name) against someone"
        info.longDescription = "Lets you create and play \(game.name) matches"
        info.helpText = game.helpText + """


            Generic subcommands (not directly related to \(game.name)):
            \(subcommands.map { "- `\($0.key)`" }.joined(separator: "\n"))
            """
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        let text = input.asText ?? ""
        if let subcommand = subcommands[text] {
            do {
                try await subcommand(output)
            } catch {
                await output.append(error, errorText: "Error while running subcommand: \(error)")
            }
            return
        }

        guard let channel = context.channel else {
            await output.append(errorText: "No channel to play on.")
            return
        }

        guard let mentions = input.asMentions, mentions.count >= 1 || game.permitsSinglePlayer else {
            await output.append(errorText: "Mention one or more users to play against.")
            return
        }
        guard let author = context.author else {
            await output.append(errorText: "Message has no author.")
            return
        }

        let flags = parseFlags(from: text)
        let players = ([author] + mentions).map { gamePlayer(from: $0, context: context) }

        // TODO: Support computer vs. computer matches without spamming the channel
        guard players.count(forWhich: \.isAutomatic) <= 1 else {
            await output.append(errorText: "Matches with multiple automatic players are currently not supported!")
            return
        }

        await startMatch(between: players, on: channel.id, output: output, flags: flags)
        context.subscribeToChannel()
    }

    private func matches(output: any CommandOutput) async {
        await output.append(.embed(Embed(
            title: ":video_game: Running \(game.name) matches",
            description: matches
                .map { "\($0.key): \($0.value.playersDescription)" }
                .joined(separator: "\n")
                .nilIfEmpty ?? "No matches"
        )))
    }

    private func parseFlags(from input: String) -> Set<String> {
        return Set(input.matches(of: flagRegex).map { String($0.1) })
    }

    private func sendHandsAsDMs(fromState state: G.State, to output: any CommandOutput) async {
        let currentPlayers = state.playersOf(role: state.currentRole)

        await withDiscardingTaskGroup { group in
            if game.onlySendHandToCurrentRole && !game.isRealTime && !currentPlayers.isEmpty {
                if let hand = state.hands[state.currentRole] {
                    for player in currentPlayers {
                        group.addTask {
                            await output.append(hand.asRichValue, to: .dmChannel(player.id))
                        }
                    }
                }
            } else {
                for (role, hand) in state.hands {
                    for player in state.playersOf(role: role) {
                        group.addTask {
                            await output.append(hand.asRichValue, to: .dmChannel(player.id))
                        }
                    }
                }
            }
        }
    }

    func startMatch(between players: [GamePlayer], on channelID: ChannelID, output: any CommandOutput, flags: Set<String> = []) async {
        do {
            var additionalMsg: RichValue = .none
            if let previousMatch = matches[channelID] {
                additionalMsg = .text("The old match \(previousMatch.playersDescription) has been cancelled in favor of this one")
            }

            var state = try G.State.init(players: players)
            try performAutomaticMoves(on: &state)

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

            await output.append(.compound([
                encodedBoard,
                additionalMsg,
                .embed(Embed(
                    title: "New match: \(state.playersDescription)",
                    color: game.themeColor.map { Int($0.rgb) },
                    footer: "Type 'help' for details!",
                    fields: [
                        Embed.Field(name: "Game actions", value: listFormat(game.actions.keys), inline: true),
                        Embed.Field(name: "General actions", value: listFormat(defaultActions.keys), inline: true),
                        Embed.Field(name: "Info", value: describeTurn(in: state), inline: false)
                    ]
                ))
            ]))
            await sendHandsAsDMs(fromState: state, to: output)
        } catch let GameError.invalidPlayerCount(reason) {
            await output.append(errorText: "Invalid player count: \(reason)")
        } catch {
            await output.append(error, errorText: "Could not create match")
        }
    }

    private func listFormat<T: Sequence>(_ sequence: T) -> String where T.Element: StringProtocol {
        return sequence.joined(separator: "\n")
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async {
        guard let author = context.author.map({ gamePlayer(from: $0, context: context) }) else { return }

        if let actionArgs = try? actionMessageRegex.firstMatch(in: content), let channel = context.channel, let sink = context.sink {
            // TODO: Remove once onSubscriptionMessage is async
            Task {
                let channelName = await sink.guildForChannel(channel.id)?.channels[channel.id]?.name
                let continueSubscription = await perform(String(actionArgs.1), withArgs: String(actionArgs.2 ?? ""), on: channel.id, channelName: channelName, output: output, author: author)
                if !continueSubscription {
                    context.unsubscribeFromChannel()
                }
            }
        }
    }

    private func gamePlayer(from user: User, context: CommandContext) -> GamePlayer {
        GamePlayer(from: user, isAutomatic: user.id == context.sink?.me?.id)
    }

    /// Performs a game action if present, otherwise does nothing. Returns whether to continue the subscription.
    /// Automatically performs subsequent computer moves as needed.
    @discardableResult
    func perform(_ actionKey: String, withArgs args: String, on channelID: ChannelID, channelName: String? = nil, output: any CommandOutput, author: GamePlayer) async -> Bool {
        guard let state = matches[channelID], (author.isUser || game.apiActions.contains(actionKey) || defaultApiActions.contains(actionKey)) else { return true }
        let output = BufferedOutput(output)
        var continueSubscription: Bool = true

        // TODO: The interaction between BufferedOutput and async/await is not
        // ideal here. Ideally, we would like to perform an (awaited) flush in
        // the deinitializer, but Swift does not seem to provide a way to do
        // that. The next best solution would be something like this:
        //
        //     defer { await output.flush() }
        //
        // ...to ensure that both all outputs are flushed after the method
        // exits, which is mostly important for tests. Unfortunately, Swift
        // does not allow asynchronous defer blocks, so we have to manually
        // guard scope exits.

        do {
            let params = ActionParameters(
                args: args,
                state: state,
                apiEnabled: apiEnabled,
                player: author,
                channelName: channelName
            )
            guard let actionResult = try game.actions[actionKey]?(params) ?? defaultActions[actionKey]?(game, params) else { return true }

            guard !actionResult.onlyCurrentPlayer
                || game.isRealTime
                || state.rolesOf(player: author).contains(state.currentRole) else {
                await output.append(errorText: "It is not your turn, `\(author.username)`")
                await output.flush()
                return true
            }

            if actionResult.cancelsMatch {
                matches[channelID] = nil
                await output.append("Cancelled match: \(state.playersDescription)")
                await output.flush()
                return false
            }

            if var next = actionResult.nextState {
                try performAutomaticMoves(on: &next)

                // Output user's hands
                await sendHandsAsDMs(fromState: next, to: output)

                let gameOver = next.isGameOver

                if gameOver {
                    // Game is over
                    matches[channelID] = nil
                    continueSubscription = false
                } else {
                    // Advance the game
                    matches[channelID] = next
                }

                if !silent || !continueSubscription {
                    // Output next board
                    await output.append(render(state: next, additionalText: actionResult.text, additionalFiles: actionResult.files))
                }

                if gameOver, let finalAction = try game.finalAction.flatMap({ try game.actions[$0]?(ActionParameters(state: next, player: author, channelName: channelName)) }) {
                    await output.append(.files(finalAction.files))
                }
            } else {
                if let text = actionResult.text {
                    await output.append(text)
                }

                if !actionResult.files.isEmpty {
                    await output.append(.files(actionResult.files))
                }
            }
        } catch GameError.invalidMove(let msg) {
            await output.append(errorText: "Invalid move by \(describe(role: state.currentRole, in: state)): \(msg)")
        } catch GameError.ambiguousMove(let msg) {
            await output.append(errorText: "Ambiguous move by \(describe(role: state.currentRole, in: state)): \(msg)")
        } catch GameError.incompleteMove(let msg) {
            await output.append(errorText: "Ambiguous move by \(describe(role: state.currentRole, in: state)): \(msg)")
        } catch GameError.moveOutOfBounds(let msg) {
            await output.append(errorText: "Move by \(describe(role: state.currentRole, in: state)) out of bounds: \(msg)")
        } catch {
            await output.append(error, errorText: "Error while performing move")
        }

        await output.flush()

        return continueSubscription
    }

    private func performAutomaticMoves(on state: inout G.State) throws {
        if let engine = game.engine {
            do {
                // TODO: This would be an issue if all players are automatic, which is currently forbidden
                while !state.isGameOver && state.playersOf(role: state.currentRole).contains(where: \.isAutomatic) {
                    let move = try engine.pickMove(from: state)
                    try state.perform(move: move)
                }
            }
        }
    }

    private func render(state: G.State, additionalText: String? = nil, additionalFiles: [Message.FileUpload] = []) -> RichValue {
        var embed: Embed? = nil

        if let winner = state.winner {
            embed = Embed(
                title: ":crown: Winner",
                description: "\(describe(role: winner, in: state)) won the game!"
            )
        } else if state.isDraw {
            embed = Embed(
                title: ":crown: Game Over",
                description: "The game resulted in a draw!"
            )
        } else {
            embed = Embed(
                description: [
                    additionalText,
                    state.handsDescription.map { "Hands: \($0)" },
                    describeTurn(in: state)
                ].compactMap { $0 }.joined(separator: "\n").nilIfEmpty
            )
        }

        let encodedBoard = state.board.asRichValue

        return .compound([
            encodedBoard,
            .embed(embed),
            .files(additionalFiles)
        ])
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
