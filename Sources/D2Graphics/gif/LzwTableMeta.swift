struct LzwTableMeta {
	public let colorCount: Int
	public let minCodeSize: Int
	public let clearCode: Int
	public let endOfInfoCode: Int
	
	public private(set) var codeSize: Int
    
    public init(colorCount: Int) {
        self.colorCount = colorCount
		
		// Find the smallest power of two that is
		// greater than or equal to the color count
		var size = 2
		while (1 << size) < colorCount {
			size += 1
		}
		minCodeSize = size
        
        clearCode = 1 << minCodeSize
        endOfInfoCode = clearCode + 1
		codeSize = -1 // set in reset()

		resetCodeSize()
    }
	
	mutating func updateCodeSize(count: Int) {
		if (count - 1) == (1 << codeSize) {
			codeSize += 1
		}
	}
	
	mutating func resetCodeSize() {
		codeSize = minCodeSize + 1
	}
}
