import Foundation

public struct Pokedex: Codable {
    public let count: Int
    public let next: URL?
    public let previous: URL?
    public let results: [NamedPokemonResource]
}
