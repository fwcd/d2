import D2MessageIO
import D2NetAPIs
import Utils

public class PokeQuizCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Lets you guess the name of a Pokémon",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true
    )
    private var quizzes: [ChannelID: Quiz] = [:]

    private struct Quiz {
        public let pokemon: Pokemon
        public let player: UserID?
    }

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        PokedexQuery().perform()
            .map { $0.results[Int.random(in: 0..<$0.results.count)] }
            .then { PokemonQuery(url: $0.url).perform() }
            .listen {
                do {
                    let pokemon = try $0.get()
                    guard let channelId = context.channel?.id else {
                        output.append(errorText: "No channel ID available.")
                        return
                    }

                    output.append(Embed(
                        title: "Which Pokémon is this?",
                        image: pokemon.sprites?.url.map(Embed.Image.init(url:))
                    ))

                    self.quizzes[channelId] = Quiz(pokemon: pokemon, player: context.author?.id)
                    context.subscribeToChannel()
                } catch {
                    output.append(error, errorText: "Could not fetch Pokédex.")
                }
            }
    }

    public func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id,
            let quiz = quizzes[channelId],
            quiz.player == context.author?.id else { return }

        let name = quiz.pokemon.name
        let distance = content.levenshteinDistance(to: name, caseSensitive: false)

        if distance == 0 {
            output.append(":partying_face: Hooray, you guessed correctly!")
        } else if distance < 2 {
            output.append(":ok_hand: You were close, the correct answer was `\(name)`.")
        } else {
            output.append(":shrug: Your guess was \(distance) \("character".pluralized(with: distance)) away from the correct name `\(name)`.")
        }

        quizzes[channelId] = nil
        context.unsubscribeFromChannel()
    }
}
