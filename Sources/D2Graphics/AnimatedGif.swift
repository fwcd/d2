import Foundation

public struct AnimatedGif {
	private let width: UInt16
	private let height: UInt16
	public private(set) var data: Data
	
	private let colorResolution: UInt8 = 0b111 // Between 0 and 8 (exclusive) -> Will be interpreted as bits per pixel - 1
	private let colorsPerChannel: UInt8 = 6
	private let colorStride: UInt8
	public let colorCount: Int
	
	/**
	 * Creates a new AnimatedGif with the specified
	 * dimensions. A loop count of 0 means infinite
	 * loops.
	 */
	public init(width: UInt16, height: UInt16, loopCount: UInt16 = 0) {
		data = Data()
		self.width = width
		self.height = height
		
		let intColorsPerChannel = Int(colorsPerChannel)
		colorStride = UInt8(256 / intColorsPerChannel)
		
		colorCount = intColorsPerChannel * intColorsPerChannel * intColorsPerChannel + 1
		
		// See http://giflib.sourceforge.net/whatsinagif/bits_and_bytes.html for a detailed explanation of the format
		appendHeader()
		appendLogicalScreenDescriptor()
		appendGlobalColorTable()
		appendLoopingApplicationExtensionBlock(loopCount: loopCount)
	}
	
	private mutating func append(byte: UInt8) {
		data.append(byte)
	}
	
	private mutating func append(short: UInt16) {
		data.append(UInt8(short & 0xFF))
		data.append(UInt8((short >> 8) & 0xFF))
	}
	
	private mutating func append(string: String) {
		data.append(string.data(using: .utf8)!)
	}
	
	struct PackedFieldByte {
		private(set) var rawValue: UInt8 = 0
		private var bitIndex: Int = 0
		
		private subscript(_ bitIndex: Int) -> UInt8 {
			get { return (rawValue >> (7 - bitIndex)) }
			set(newValue) { rawValue = rawValue | (newValue << (7 - bitIndex)) }
		}
		
		/**
		 * Appends a value to the bitfield
		 * by converting it to little-endian
		 * and masking it.
		 */
		mutating func append(_ appended: UInt8, bits: Int) {
			assert(bitIndex < 8)
			let mask: UInt8 = (1 << UInt8(bits)) - 1
			let masked = appended & mask
			rawValue = rawValue | (masked << ((8 - bits) - bitIndex))
			bitIndex += bits
		}
		
		mutating func append(_ flag: Bool) {
			append(flag ? 1 : 0, bits: 1)
		}
	}
	
	private mutating func appendHeader() {
		append(string: "GIF89a")
	}
	
	private mutating func appendLogicalScreenDescriptor() {
		append(short: width)
		append(short: height)
		
		let useGlobalColorTable = true
		let sortFlag = false
		let sizeOfGlobalColorTable: UInt8 = colorResolution
		
		var packedField = PackedFieldByte()
		packedField.append(useGlobalColorTable)
		packedField.append(colorResolution, bits: 3)
		packedField.append(sortFlag)
		packedField.append(sizeOfGlobalColorTable, bits: 3)
		append(byte: packedField.rawValue)
		
		let backgroundColorIndex: UInt8 = 0
		let pixelAspectRatio: UInt8 = 0
		append(byte: backgroundColorIndex)
		append(byte: pixelAspectRatio)
	}
	
	private mutating func appendGlobalColorTable() {
		// Generate a standard color table of 6 colors per channel distributed uniformly
		
		// TODO: Use a better quantization algorithm, preferably
		// generating a per-frame color table instead of a global one
		var index = 0
		
		for r in 0..<colorsPerChannel {
			for g in 0..<colorsPerChannel {
				for b in 0..<colorsPerChannel {
					append(byte: r * colorStride)
					append(byte: g * colorStride)
					append(byte: b * colorStride)
					index += 3
				}
			}
		}
		
        let maxIndex = 256 * 3
		while index < maxIndex {
			append(byte: 0)
			index += 1
		}
	}
	
	private mutating func appendLoopingApplicationExtensionBlock(loopCount: UInt16) {
		append(byte: 0x21) // Extension introducer
		append(byte: 0xFF) // Application extension
		append(byte: 0x0B) // Block size
		append(string: "NETSCAPE2.0")
		append(byte: 0x03) // Block size
		append(byte: 0x01) // Loop indicator
		append(short: loopCount)
		append(byte: 0x00) // Block terminator
	}
	
	private func encode(argb: UInt32) -> Int {
		return encode(color: Color(argb: argb))
	}
	
	private func encode(color: Color) -> Int {
		// Implementation is consistent with the global color table
		if color.alpha == 0 {
			// Fully transparent color is stored in the last field
			// of the colors
			return colorCount - 1
		} else {
			let r = Int(color.red / colorStride)
			let g = Int(color.green / colorStride)
			let b = Int(color.blue / colorStride)
			return colorTableIndexOf(r: r, g: g, b: b)
		}
	}
	
	private func colorTableIndexOf(r: Int, g: Int, b: Int) -> Int {
		return (36 * r * g) + (6 * g) + b
	}
	
	private mutating func appendGraphicsControlExtension(delayTime: UInt16) {
		append(byte: 0x21) // Extension introducer
		append(byte: 0xF9) // Graphics control label
		append(byte: 0x04) // Block size in bytes
		
		let disposalMethod: UInt8 = 0
		let userInputFlag = false
		let transparentColorFlag = true
		
		var packedField = PackedFieldByte()
        packedField.append(0, bits: 3)
		packedField.append(disposalMethod, bits: 3)
		packedField.append(userInputFlag)
		packedField.append(transparentColorFlag)
		append(byte: packedField.rawValue)
		
		append(short: delayTime)
		append(byte: 0xFF) // Transparent color index
		append(byte: 0x00) // Block terminator
	}
	
	private mutating func appendImageDescriptor() {
		append(byte: 0x2C) // Image separator
		append(short: 0) // Left position
		append(short: 0) // Top position
		append(short: width)
		append(short: height)
		
		let localColorTableFlag = false
		let interlaceFlag = false
		let sortFlag = false
		let sizeOfLocalColorTable: UInt8 = 0
		
		var packedField = PackedFieldByte()
		packedField.append(localColorTableFlag)
		packedField.append(interlaceFlag)
		packedField.append(sortFlag)
		packedField.append(0, bits: 2)
		packedField.append(sizeOfLocalColorTable, bits: 3)
		append(byte: packedField.rawValue)
	}
	
	private mutating func appendImageDataAsLZW(frame: Image) {
		// Convert the ARGB-encoded image first to color
		// indices and then to LZW-compressed codes
		var encoder = LzwEncoder(colorCount: colorCount)
		let surface = frame.surface // The Cairo surface behind the image
		
		print("LZW-encoding the frame...")
		// Iterate all pixels as ARGB values and encode them
		surface.withUnsafeMutableBytes { ptr in
			let pixelCount = surface.width * surface.height
			var i = 0
			for _ in 0..<pixelCount {
				let color = Color(
					red: ptr[i + 1],
					green: ptr[i + 2],
					blue: ptr[i + 3],
					alpha: ptr[i]
				)
				encoder.encodeAndAppend(index: encode(color: color))
				i += 3
			}
		}
		encoder.finishEncoding()
        
		print("Appending the encoded frame...")
		append(byte: UInt8(encoder.minCodeSize))
		
		let lzwEncoded = encoder.bytes
		var byteIndex = 0
		while byteIndex < lzwEncoded.count {
			let subBlockByteCount = min(0xFF, lzwEncoded.count - byteIndex)
			append(byte: UInt8(subBlockByteCount))
			for _ in 0..<subBlockByteCount {
				append(byte: lzwEncoded[byteIndex])
				byteIndex += 1
			}
		}
		
		append(byte: 0x00) // Block terminator
	}
	
	/**
	 * Appends a frame with the specified delay time
	 * (in milliseconds).
	 */
	public mutating func append(frame: Image, delayTime: UInt16) throws {
		let frameWidth = UInt16(frame.width)
		let frameHeight = UInt16(frame.height)
		assert(frameWidth == width)
		assert(frameHeight == height)
		
		if frameWidth != width || frameHeight != height {
			throw AnimatedGifError.frameSizeMismatch(frame.width, frame.height, Int(width), Int(height))
		}
		
		appendGraphicsControlExtension(delayTime: delayTime)
		appendImageDescriptor()
		appendImageDataAsLZW(frame: frame)
	}
    
    public mutating func appendTrailer() {
        append(byte: 0x3B)
    }
}
