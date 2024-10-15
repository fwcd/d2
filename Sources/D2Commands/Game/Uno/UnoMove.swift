import Utils

private let rawColorPattern = "(?:\(UnoColor.allCases.map { $0.rawValue }.joined(separator: "|")))"
private let rawLabelPattern = "(?:\(UnoActionLabel.allCases.map { $0.rawValue }.joined(separator: "|")))"
nonisolated(unsafe) private let movePattern = try! Regex("^(?:(\(rawColorPattern))\\s+)?(\(rawLabelPattern)|[0-9])(?:\\s+(\(rawColorPattern)))?$")

public struct UnoMove: Hashable {
    public let card: UnoCard?
    public let drawsCard: Bool
    public let nextColor: UnoColor?

    public init(playing card: UnoCard? = nil, drawingCard drawsCard: Bool = false, pickingColor nextColor: UnoColor? = nil) {
        self.card = card
        self.drawsCard = drawsCard
        self.nextColor = nextColor
    }

    public init(fromString str: String) throws {
        if str == "draw" {
            self.init(drawingCard: true)
        } else if let parsed = try? movePattern.firstMatch(in: str) {
            let rawColor = String(parsed[1].substring ?? "")
            let rawLabel = String(parsed[2].substring ?? "")
            let rawNextColor = String(parsed[3].substring ?? "")
            self.init(
                playing: try UnoCard.from(rawLabelOrNum: rawLabel, rawColor: rawColor.nilIfEmpty),
                pickingColor: UnoColor(rawValue: rawNextColor)
            )
        } else {
            throw GameError.invalidMove("Your move `\(str)` is invalid, try `[card color]? [card label] [next color]?`")
        }
    }
}
