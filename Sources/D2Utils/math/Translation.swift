public struct Translation<T: Addable & Subtractable>: Bijection {
    private let offset: T

    public init(by offset: T) {
        self.offset = offset
    }

    public func apply(_ value: T) -> T {
        return value + offset
    }

    public func inverseApply(_ value: T) -> T {
        return value - offset
    }
}
