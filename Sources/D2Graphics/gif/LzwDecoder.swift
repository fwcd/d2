// Based on http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html
struct LzwDecoder {
    private(set) var table: LzwDecoderTable
    
    public private(set) var decoded: [Int] = [] // The decoded indices
    private var lastCode: UInt8? = nil
    
    public init(colorCount: Int) {
        table = LzwDecoderTable(colorCount: colorCount)
    }
    
    public mutating func decodeAndAppend(code: UInt8) throws {
        let codeInt = Int(code)
        if let lastCodeInt = lastCode.map(Int.init) {
            // The main LZW decoding algorithm
            if code == table.meta.clearCode {
                table.reset()
            } else if let indices = table[codeInt] {
                guard var nextIndices = table[lastCodeInt] else { throw LzwCodingError.tableTooSmall }
                guard let k = indices.first else { throw LzwCodingError.decodedIndicesEmpty }
                decoded += indices
                nextIndices.append(k)
                table.append(indices: nextIndices)
            } else {
                guard var indices = table[lastCodeInt] else { throw LzwCodingError.tableTooSmall }
                guard let k = indices.first else { throw LzwCodingError.decodedIndicesEmpty }
                decoded += indices
                indices.append(k)
                table.append(indices: indices)
            }
        }
        lastCode = code
    }
}
