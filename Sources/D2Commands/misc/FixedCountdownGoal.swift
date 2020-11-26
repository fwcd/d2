import Foundation

public struct FixedCountdownGoal: CountdownGoal {
    public let date: Date

    public init(date: Date) {
        self.date = date
    }
}
