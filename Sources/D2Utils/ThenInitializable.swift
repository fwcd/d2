public protocol ThenInitializable {
    associatedtype Value

    init(then: @escaping (Value) -> Void)
}
