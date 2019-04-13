public struct Scaling<T: Multipliable & Divisible>: Bijection {
	private let factor: T
	
	public init(by factor: T) {
		self.factor = factor
	}
	
	public func apply(_ value: T) -> T {
		return value * factor
	}
	
	public func inverseApply(_ value: T) -> T {
		return value / factor
	}
}
