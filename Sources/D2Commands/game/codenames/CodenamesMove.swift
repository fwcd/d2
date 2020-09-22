import D2Utils

public struct CodenamesMove: Hashable {
    public let words: [String]

    public init(fromString str: String) throws {
        words = str.split(separator: " ").map(String.init)
    }
}
