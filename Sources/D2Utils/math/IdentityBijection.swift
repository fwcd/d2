public struct IdentityBijection<V>: Bijection {
    public init() {}

    public func apply(_ value: V) -> V { value }

    public func inverseApply(_ value: V) -> V { value }
}
