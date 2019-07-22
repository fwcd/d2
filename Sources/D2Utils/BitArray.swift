public struct BitArray {
	public private(set) var bytes: [UInt8] = []
	private var next = 0
	
	public init() {}
	
	public subscript(boolAt index: Int) -> Bool {
		get { return self[bitAt: index] == 1 }
		set(newValue) { self[bitAt: index] = (newValue ? 1 : 0) }
	}
	
	public subscript(bitAt index: Int) -> UInt8 {
		get { return (bytes[index / 8] >> (7 - (index % 8))) & 1 }
		set(newValue) {
			let byteIndex = index / 8
			let bitIndex = index % 8
			while bytes.count <= byteIndex {
				bytes.append(0)
			}
			
			let previousByte: UInt8 = bytes[byteIndex]
			let newBit: UInt8 = newValue & 1
			let newByte: UInt8 = previousByte | (newBit << (7 - bitIndex))
			bytes[index / 8] = newByte
		}
	}
	
	public mutating func append(bool: Bool) {
		append(bit: bool ? 1 : 0)
	}
	
	public mutating func append(bit: UInt8) {
		self[bitAt: next] = bit
		next += 1
	}
}
