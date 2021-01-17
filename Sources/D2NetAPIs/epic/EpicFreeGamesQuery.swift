import Utils

public struct EpicFreeGamesQuery {
    public init() {}

    public func perform() -> Promise<[EpicFreeGame], Error> {
        Promise.catching { try HTTPRequest(host: "www.epicgames.com", path: "/store/en-US/free-games") }
            .then { $0.fetchHTMLAsync() }
            .mapCatching { document in
                try document
                    .select("div[data-component=\"OfferCard\"]")
                    .array()
                    .compactMap { card in
                        guard
                            let title = try card.select("div[data-testid=\"offer-title-info-title\"]").first()?.text(),
                            let subtitle = try card.select("div[data-testid=\"offer-title-info-subtitle\"]").first()?.text() else { return nil }
                        return EpicFreeGame(title: title, subtitle: subtitle)
                    }
            }
    }
}
