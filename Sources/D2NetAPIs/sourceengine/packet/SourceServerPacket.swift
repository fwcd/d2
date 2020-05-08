import Foundation

public struct SourceServerPacket {
    public private(set) var data: Data
    
    public init(data: Data) {
        self.data = data
    }

    public init(header: UInt8) {
        data = Data()
        
        write(long: 0xFFFFFFFF)
        write(byte: header)
    }
    
    public mutating func write(string: String) {
        data.append(string.data(using: .utf8)!)
        data.append(0x00)
    }
    
    public mutating func write(byte: UInt8) {
        data.append(byte)
    }
    
    public mutating func write(long: UInt32) {
        data.append(UInt8((long >> 24) & 0xFF))
        data.append(UInt8((long >> 16) & 0xFF))
        data.append(UInt8((long >> 8) & 0xFF))
        data.append(UInt8(long & 0xFF))
    }
    
    public mutating func write(float: Float32) {
        write(long: float.bitPattern)
    }
    
    public mutating func readString() -> String? {
        var encoded = Data()
        while let b = data.popFirst(), b != 0 {
            encoded.append(b)
        }
        return String(data: encoded, encoding: .utf8)
    }
    
    public mutating func readByte() -> UInt8? {
        data.popFirst()
    }
    
    public mutating func readShort() -> UInt16? {
        guard let le = data.popFirst(), let be = data.popFirst() else { return nil }
        return UInt16(littleEndian: (UInt16(le) << 8) | UInt16(be))
    }
    
    public mutating func readLong() -> UInt32? {
        guard let fst = data.popFirst(),
            let snd = data.popFirst(),
            let thd = data.popFirst(),
            let fth = data.popFirst() else { return nil }
        return UInt32(littleEndian: (UInt32(fst) << 24) | (UInt32(snd) << 16) | (UInt32(thd) << 8) | UInt32(fth))
    }
    
    public mutating func readFloat() -> Float32? {
        readLong().map(Float32.init(bitPattern:))
    }
}
