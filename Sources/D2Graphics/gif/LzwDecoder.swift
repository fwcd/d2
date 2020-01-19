// Based on http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html
struct LzwDecoder {
    private(set) var table: LzwDecoderTable
    
    public private(set) var decoded: [Int] = [] // The decoded indices
    private var lastCode: Int? = nil
    
    public var minCodeSize: Int { return table.meta.minCodeSize }
    
    public init(colorCount: Int) {
        table = LzwDecoderTable(colorCount: colorCount)
    }
    
    private mutating func decodeAndAppend(code: Int) throws {
        if let lastCode = lastCode {
            // The main LZW decoding algorithm
            if code == table.meta.clearCode {
                table.reset()
            } else if let indices = table[code] {
                guard var nextIndices = table[lastCode] else { throw LzwCodingError.tableTooSmall }
                guard let k = indices.first else { throw LzwCodingError.decodedIndicesEmpty }
                decoded += indices
                nextIndices.append(k)
                table.append(indices: nextIndices)
            } else {
                guard var indices = table[lastCode] else { throw LzwCodingError.tableTooSmall }
                guard let k = indices.first else { throw LzwCodingError.decodedIndicesEmpty }
                decoded += indices
                indices.append(k)
                table.append(indices: indices)
            }
        }
        lastCode = code
    }
}
