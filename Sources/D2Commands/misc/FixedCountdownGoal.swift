import Foundation

public struct FixedCountdownGoal: CountdownGoal {
    public let date: Date
    public var removeAfterCompletion: Bool { return true }
    
    public init(date: Date) {
        self.date = date
    }
}
