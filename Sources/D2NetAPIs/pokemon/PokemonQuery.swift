import Foundation
import Utils

public struct PokemonQuery {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func perform() -> Promise<Pokemon, any Error> {
        HTTPRequest(url: url).fetchJSONAsync(as: Pokemon.self)
    }
}
