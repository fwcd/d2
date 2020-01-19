import Foundation

/**
 * Enables reading and writing chunks of individual
 * bits in a byte buffer. Note that bits are written
 * from **right (LSB) to left (MSB)** inside a byte.
 */
public struct BitData {
    public private(set) var data: Data
    private var byteIndex: Int = 0
    private var bitIndexFromRight: UInt = 0 { // ...inside the current byte
        didSet {
            if bitIndexFromRight >= 8 {
                data.append(0)
                byteIndex += 1
                bitIndexFromRight = 0
            }
        }
    }
    private var remainingBitsInByte: UInt { 8 - bitIndexFromRight }

    public init(from data: Data = Data([0])) {
        self.data = data
    }

    /** Writes the rightmost `bitCount` bits from the value. **/
    public mutating func write(_ value: UInt, bitCount initialBitCount: UInt) {
        var bitCount = initialBitCount
        while bitCount > 0 {
            let c = min(bitCount, remainingBitsInByte)
            let i = initialBitCount - bitCount
            writeIntoCurrentByte(value >> i, bitCount: c)
            bitCount -= c
        }
    }
    
    public mutating func read(bitCount initialBitCount: UInt) -> UInt {
        assert(Int(initialBitCount) <= UInt.bitWidth)
        var bitCount: UInt = initialBitCount
        var value: UInt = 0
        while bitCount > 0 {
            let c = min(bitCount, remainingBitsInByte)
            let i = initialBitCount - bitCount
            print("@\(i)")
            value |= readFromCurrentByte(bitCount: c) << i
            print("done@\(i)")
            bitCount -= c
        }
        return value
    }
    
    private mutating func writeIntoCurrentByte(_ value: UInt, bitCount: UInt) {
        let oldByte = data[byteIndex]
        let mask: UInt = maskOfOnes(bitCount: UInt(bitCount))
        data[byteIndex] = oldByte | UInt8((value & mask) << bitIndexFromRight)
        bitIndexFromRight += bitCount
    }
    
    private mutating func readFromCurrentByte(bitCount: UInt) -> UInt {
        let byte = data[byteIndex]
        let mask: UInt = maskOfOnes(bitCount: bitCount)
        let value = UInt(byte >> bitIndexFromRight) & mask
        bitIndexFromRight += bitCount
        return value
    }
    
    private func maskOfOnes<U>(bitCount: U) -> U where U: FixedWidthInteger {
        assert(bitCount <= U.bitWidth)
        if bitCount == U.bitWidth {
            return U.max
        } else {
            return (1 << bitCount) - 1
        }
    }
}
