import D2Utils

public protocol PickupLineQuery {
    func perform() -> Promise<PickupLine, Error>
}
