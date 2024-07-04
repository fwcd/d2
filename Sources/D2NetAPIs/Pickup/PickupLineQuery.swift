import Utils

public protocol PickupLineQuery {
    func perform() async throws -> PickupLine
}
