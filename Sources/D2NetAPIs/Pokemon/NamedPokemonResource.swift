import Foundation

public struct NamedPokemonResource: Sendable, Codable {
    public let name: String
    public let url: URL
}
