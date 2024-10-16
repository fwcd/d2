import Utils

public protocol PickupLineQuery: Sendable {
    func perform() async throws -> PickupLine
}
