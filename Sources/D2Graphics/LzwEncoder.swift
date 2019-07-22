// Based on http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html
import D2Utils

fileprivate let maxCodeTableCount: Int = 1 << 12

struct LzwEncoder {
	private var table: LzwEncoderTable
	public private(set) var bits = BitArray()
	private var indexBuffer: [Int] = []
	
	public var minCodeSize: Int { return table.minCodeSize }
	
	public init(colorCount: Int) {
		table = LzwEncoderTable(colorCount: colorCount)
        write(code: table.clearCode)
	}
	
	public mutating func encodeAndAppend(index: Int) {
		// The main LZW encoding algorithm
		let extendedBuffer = indexBuffer + [index]
		if table.contains(indices: extendedBuffer) {
			indexBuffer = extendedBuffer
		} else {
			write(code: table[indexBuffer]!)
			if table.count >= maxCodeTableCount {
				write(code: table.clearCode)
				table.reset()
			} else {
				table.append(indices: extendedBuffer)
			}
            indexBuffer = [index]
		}
	}
    
    public mutating func finishEncoding() {
        write(code: table[indexBuffer]!)
        write(code: table.endOfInfoCode)
    }
	
	private mutating func write(code: Int) {
		let unsigned = UInt(code)
		for i in 0..<table.codeSize {
			bits.append(bit: UInt8((unsigned >> i) & 1))
		}
	}
}
