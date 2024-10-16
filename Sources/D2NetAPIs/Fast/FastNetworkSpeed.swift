public struct FastNetworkSpeed: Sendable {
    public let megabits: Double
    public let seconds: Double

    public var megabitsPerSecond: Double {
        megabits / seconds
    }

    public static func +(lhs: Self, rhs: Self) -> Self {
        FastNetworkSpeed(
            megabits: lhs.megabits + rhs.megabits,
            seconds: lhs.seconds + rhs.seconds
        )
    }
}
