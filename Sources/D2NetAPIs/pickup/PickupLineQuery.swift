public protocol PickupLineQuery {
    func perform(then: @escaping (Result<PickupLine, Error>) -> Void)
}
