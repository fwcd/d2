public struct ComposedBijection<B, C>: Bijection where B: Bijection, C: Bijection, B.Value == C.Value {
    public typealias Value = B.Value

    private let outer: B
    private let inner: C

    public init(outer: B, inner: C) {
        self.outer = outer
        self.inner = inner
    }

    public func apply(_ value: Value) -> Value {
        outer.apply(inner.apply(value))
    }

    public func inverseApply(_ value: Value) -> Value {
        inner.inverseApply(outer.inverseApply(value))
    }
}

extension Bijection {
    public func then<B: Bijection>(_ outer: B) -> ComposedBijection<B, Self> where B.Value == Value {
        ComposedBijection(outer: outer, inner: self)
    }

    public func compose<B: Bijection>(_ inner: B) -> ComposedBijection<Self, B> where B.Value == Value {
        ComposedBijection(outer: self, inner: inner)
    }
}
