public protocol Bijection {
	associatedtype Value
	
	func apply(_ value: Value) -> Value
	
	func inverseApply(_ value: Value) -> Value
}
