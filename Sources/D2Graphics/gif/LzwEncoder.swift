// Based on http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html
import D2Utils

fileprivate let maxCodeTableCount: Int = 1 << 12

struct LzwEncoder {
	private(set) var table: LzwEncoderTable
	private var indexBuffer: [Int] = []
	
	public private(set) var encoded: [UInt8] = [0] // The encoded bytes
	private var bitIndexFromRight: Int = 0 // ...inside the current byte
	
	public var minCodeSize: Int { return table.meta.minCodeSize }
	
	public init(colorCount: Int) {
		table = LzwEncoderTable(colorCount: colorCount)
        write(code: table.meta.clearCode)
	}
	
	public mutating func encodeAndAppend(index: Int) {
		// The main LZW encoding algorithm
		let extendedBuffer = indexBuffer + [index]
		if table.contains(indices: extendedBuffer) {
			indexBuffer = extendedBuffer
		} else {
			write(code: table[indexBuffer]!)
			if table.count >= maxCodeTableCount {
				write(code: table.meta.clearCode)
				table.reset()
			} else {
				table.append(indices: extendedBuffer)
			}
            indexBuffer = [index]
		}
	}
    
    public mutating func finishEncoding() {
        write(code: table[indexBuffer]!)
        write(code: table.meta.endOfInfoCode)
    }
	
	private mutating func write(code: Int) {
		let unsignedCode = UInt(code)
		for i in 0..<table.codeSize {
			append(bit: UInt8((unsignedCode >> i) & 1))
		}
	}
	
	private mutating func append(bit: UInt8) {
		let byteIndex = encoded.count - 1
		let oldByte = encoded[byteIndex]
		encoded[byteIndex] = oldByte | (bit << bitIndexFromRight)
		bitIndexFromRight += 1
		
		if bitIndexFromRight >= 8 {
			encoded.append(0)
			bitIndexFromRight = 0
		}
	}
}
