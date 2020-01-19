struct LzwTableMeta {
	public let colorCount: Int
	public let minCodeSize: Int
	public let clearCode: Int
	public let endOfInfoCode: Int
    
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
    }
}
