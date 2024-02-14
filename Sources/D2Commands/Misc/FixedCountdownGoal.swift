import Foundation

public struct FixedCountdownGoal: Codable, CountdownGoal {
    public let date: Date

    public init(date: Date) {
        self.date = date
    }
}
