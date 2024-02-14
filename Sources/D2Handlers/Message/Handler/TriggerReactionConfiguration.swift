// TODO: Move this to D2Commands and add a command for configuring these

public struct TriggerReactionConfiguration: Codable {
    public var dateSpecificReactions: Bool
    public var weatherReactions: Bool

    public init(
        dateSpecificReactions: Bool = true,
        weatherReactions: Bool = true
    ) {
        self.dateSpecificReactions = dateSpecificReactions
        self.weatherReactions = weatherReactions
    }
}
