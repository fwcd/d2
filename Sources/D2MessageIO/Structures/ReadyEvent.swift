public struct ReadyEvent: Sendable, Hashable {
    public let gatewayVersion: Int?
    public let shard: [Int]?

    public init(
        gatewayVersion: Int? = nil,
        shard: [Int]? = nil
    ) {
        self.gatewayVersion = gatewayVersion
        self.shard = shard
    }
}
