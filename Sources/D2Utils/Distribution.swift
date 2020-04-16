public protocol Distribution {
    associatedtype Element

    /// (Randomly) samples a value from the distribution.
    func sample() -> Element
}
