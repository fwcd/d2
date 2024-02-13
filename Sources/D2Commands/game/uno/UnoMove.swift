import Utils

fileprivate let rawColorPattern = "(?:\(UnoColor.allCases.map { $0.rawValue }.joined(separator: "|")))"
fileprivate let rawLabelPattern = "(?:\(UnoActionLabel.allCases.map { $0.rawValue }.joined(separator: "|")))"
fileprivate let movePattern = try! LegacyRegex(from: "^(?:(\(rawColorPattern))\\s+)?(\(rawLabelPattern)|[0-9])(?:\\s+(\(rawColorPattern)))?$")

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
        } else if let parsed = movePattern.firstGroups(in: str) {
            let rawColor = parsed[1]
            let rawLabel = parsed[2]
            let rawNextColor = parsed[3]
            self.init(
                playing: try UnoCard.from(rawLabelOrNum: rawLabel, rawColor: rawColor.nilIfEmpty),
                pickingColor: UnoColor(rawValue: rawNextColor)
            )
        } else {
            throw GameError.invalidMove("Your move `\(str)` is invalid, try `[card color]? [card label] [next color]?`")
        }
    }
}
