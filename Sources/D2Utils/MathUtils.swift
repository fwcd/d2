extension Int {
	public func clockModulo(_ rhs: Int) -> Int {
		return (self % rhs + rhs) % rhs
	}
}
