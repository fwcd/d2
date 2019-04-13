public struct ClosureBijection<V>: Bijection {
	private let applyImpl: (V) -> V
	private let inverseApplyImpl: (V) -> V
	
	init(apply applyImpl: @escaping (V) -> V, inverseApply inverseApplyImpl: @escaping (V) -> V) {
		self.applyImpl = applyImpl
		self.inverseApplyImpl = inverseApplyImpl
	}
	
	public func apply(_ value: V) -> V { return applyImpl(value) }
	
	public func inverseApply(_ value: V) -> V { return inverseApplyImpl(value) }
}

public extension Bijection {
	func then<B: Bijection>(_ next: B) -> ClosureBijection<Value> where B.Value == Value {
		return ClosureBijection(
			apply: { next.apply(self.apply($0)) },
			inverseApply: { self.inverseApply(next.inverseApply($0)) }
		)
	}
}
