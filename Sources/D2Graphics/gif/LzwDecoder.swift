// Based on http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html
import D2Utils

struct LzwDecoder {
    private(set) var table: LzwDecoderTable
    private var lastCode: Int? = nil

    public var minCodeSize: Int { return table.meta.minCodeSize }
    
    public init(colorCount: Int) {
        table = LzwDecoderTable(colorCount: colorCount)
    }
    
    public mutating func decodeAndAppend(from data: inout BitData, into decoded: inout [Int]) throws {
        let code = data.read(bitCount: UInt(table.meta.codeSize))
        try decodeAndAppend(code: Int(code), into: &decoded)
    }
    
    private mutating func decodeAndAppend(code: Int, into decoded: inout [Int]) throws {
        if let lastCode = lastCode {
            // The main LZW decoding algorithm
            if code == table.meta.clearCode {
                table.reset()
            } else if let indices = table[code] {
                guard var nextIndices = table[lastCode] else { throw LzwCodingError.tableTooSmall }
                guard let k = indices.first else { throw LzwCodingError.decodedIndicesEmpty }
                decoded.append(contentsOf: indices)
                nextIndices.append(k)
                table.append(indices: nextIndices)
            } else {
                guard var indices = table[lastCode] else { throw LzwCodingError.tableTooSmall }
                guard let k = indices.first else { throw LzwCodingError.decodedIndicesEmpty }
                decoded.append(contentsOf: indices)
                indices.append(k)
                table.append(indices: indices)
            }
        }
        lastCode = code
    }
}
