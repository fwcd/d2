import Foundation

public struct Pokedex: Codable {
    public let count: Int
    public let next: URL?
    public let previous: URL?
    public let results: [Entry]

    public struct Entry: Codable {
        public let name: String
        public let url: URL
    }
}
