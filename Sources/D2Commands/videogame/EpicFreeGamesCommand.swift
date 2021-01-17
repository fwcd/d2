import D2MessageIO
import D2NetAPIs

public class EpicFreeGamesCommand: StringCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Fetches current free games from the Epic Games Store",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        EpicFreeGamesQuery().perform().listen {
            do {
                let games = try $0.get().data.catalog.searchStore.elements
                output.append(Embed(
                    title: "Free Games in the Epic Store",
                    fields: games
                        .prefix(5)
                        .map { Embed.Field(name: $0.title, value: self.format(game: $0) ?? "_no info_") }
                ))
            } catch {
                output.append(error, errorText: "Could not query games")
            }
        }
    }

    private func format(game: EpicFreeGames.ResponseData.Catalog.SearchStore.Element) -> String? {
        [
            (game.seller?.name).map { "_by \($0)_" },
            (game.price?.totalPrice?.fmtPrice).flatMap {
                [
                    ($0?.originalPrice).map { "~~\($0)~~" },
                    $0?.discountPrice
                ].compactMap { $0 }.joined(separator: " ").nilIfEmpty
            },
            game.promotions?.allOffers.first.map { "\($0)" }
        ].compactMap { $0 }.joined(separator: "\n").nilIfEmpty
    }
}
