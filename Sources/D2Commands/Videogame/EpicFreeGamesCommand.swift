import D2MessageIO
import D2NetAPIs

public class EpicFreeGamesCommand: StringCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Fetches current free games from the Epic Games Store",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let games = try await EpicFreeGamesQuery().perform().data.catalog.searchStore.elements
            await output.append(Embed(
                title: "Free Games in the Epic Store",
                fields: games
                    .prefix(5)
                    .map { Embed.Field(name: $0.title, value: self.format(game: $0) ?? "_no info_") }
            ))
        } catch {
            await output.append(error, errorText: "Could not query games")
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
