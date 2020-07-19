public struct AnyBijection<T>: Bijection {
    private let f: (T) -> T
    private let fInverse: (T) -> T

    public init(_ f: @escaping (T) -> T, _ fInverse: @escaping (T) -> T) {
        self.f = f
        self.fInverse = fInverse
    }

    public init<B>(_ bijection: B) where B: Bijection, B.Value == T {
        f = bijection.apply
        fInverse = bijection.inverseApply
    }
    
    public func apply(_ value: T) -> T {
        f(value)
    }

    public func inverseApply(_ value: T) -> T {
        fInverse(value)
    }
}
