import Utils

public protocol PickupLineQuery {
    func perform() -> Promise<PickupLine, any Error>
}
