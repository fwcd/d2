import Foundation

public protocol CountdownGoal {
    var date: Date { get }
    var removeAfterCompletion: Bool { get }
}
