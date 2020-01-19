// Based on http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html
import D2Utils

struct LzwDecoderTable {
    // Stores the mappings from single codes to multiple indices
    private(set) var entries: [[Int]] = []
	public var meta: LzwTableMeta
    
    public init(colorCount: Int) {
        meta = LzwTableMeta(colorCount: colorCount)
    }
    
    public subscript(_ code: Int) -> [Int]? {
        entries[safely: code]
    }
    
    public mutating func append(indices: [Int]) {
        entries.append(indices)
    }
    
    public mutating func reset() {
        entries = []
        meta.resetCodeSize()
    }
}
