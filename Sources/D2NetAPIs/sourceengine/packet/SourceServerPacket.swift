import Foundation

public struct SourceServerPacket {
    public private(set) var data: Data
    
    public init(data: Data) {
        self.data = data
    }

    public init(header: UInt8) {
        data = Data()
        data.append(header)
    }
    
    public mutating func write(string: String) {
        data.append(string.data(using: .utf8)!)
    }
    
    public mutating func write(byte: UInt8) {
        data.append(byte)
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
}
