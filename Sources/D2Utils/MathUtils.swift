extension Int {
	public func clockModulo(_ rhs: Int) -> Int {
		return (self % rhs + rhs) % rhs
	}
}

extension UnsignedInteger {
	public var leadingZeros: Int {
		let maxIndex = bitWidth - 1
		for i in 0..<bitWidth {
			if (self >> (maxIndex - i)) & 1 != 0 {
				return i
			}
		}
		return bitWidth
	}

	public func log2Floor() -> Int {
		return (bitWidth - 1) - leadingZeros
	}
}
