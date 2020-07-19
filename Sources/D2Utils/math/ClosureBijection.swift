public struct AnyBijection<V>: Bijection {
	private let applyImpl: (V) -> V
	private let inverseApplyImpl: (V) -> V
	
	public init(apply applyImpl: @escaping (V) -> V, inverseApply inverseApplyImpl: @escaping (V) -> V) {
		self.applyImpl = applyImpl
		self.inverseApplyImpl = inverseApplyImpl
	}

	public init<B>(_ bijection: B) where B: Bijection, B.Value == V {
		applyImpl = bijection.apply
		inverseApplyImpl = bijection.inverseApply
	}
	
	public func apply(_ value: V) -> V { return applyImpl(value) }
	
	public func inverseApply(_ value: V) -> V { return inverseApplyImpl(value) }
}
