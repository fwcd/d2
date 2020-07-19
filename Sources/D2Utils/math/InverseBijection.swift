public struct InverseBijection<B>: Bijection where B: Bijection {
    public typealias Value = B.Value

    private let inverse: B

    public init(inverting inverse: B) {
        self.inverse = inverse
    }

    public func apply(_ value: Value) -> Value {
        inverse.inverseApply(value)
    }

    public func inverseApply(_ value: Value) -> Value {
        inverse.apply(value)
    }
}

extension Bijection {
    public var inverse: InverseBijection<Self> { InverseBijection(inverting: self) }
}
