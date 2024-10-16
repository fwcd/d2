import Foundation
import Utils

public struct PokemonQuery: Sendable {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func perform() async throws -> Pokemon {
        try await HTTPRequest(url: url).fetchJSON(as: Pokemon.self)
    }
}
