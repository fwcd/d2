// Based on http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html

struct LzwEncoderTable {
	// Stores the mappings from multiple indices to a single code
	private var entries: [[Int]: Int] = [:]
	private(set) var codeSize: Int
	var count: Int
	public let meta: LzwTableMeta
	
	public init(colorCount: Int) {
		meta = LzwTableMeta(colorCount: colorCount)
		count = -1 // Will be set in reset()
		codeSize = -1 // Will be set in reset()
		
		reset()
	}
	
	public subscript(indices: [Int]) -> Int? {
		get {
			if indices.count == 1 {
				// A single index matches its color code
				return indices.first
			} else {
				return entries[indices]
			}
		}
	}
	
	public mutating func append(indices: [Int]) {
		assert(indices.count > 1)
		entries[indices] = count
		
		if count == (1 << codeSize) {
			// Increase code size
			codeSize += 1
		}
		
		count += 1
	}
	
	public func contains(indices: [Int]) -> Bool {
		return self[indices] != nil
	}
	
	public mutating func reset() {
		entries = [:]
		codeSize = meta.minCodeSize + 1
		count = (1 << meta.minCodeSize) + 2
	}
}
