import Cairo
import Foundation
import D2Utils

public struct Image {
	let surface: Surface.Image
	
	public var width: Int { return surface.width }
	public var height: Int { return surface.height }
	public var size: Vec2<Int> { return Vec2(x: width, y: height) }
	
	private var bytesPerPixel: Int? {
		switch surface.format {
			case .argb32?: return 4
			case .rgb24?: return 3
			case .a8?: return 1
			default: return nil
		}
	}
	
	init(from surface: Surface.Image) {
		self.surface = surface
	}
	
	public init(width: Int, height: Int) throws {
		self.init(from: try Surface.Image(format: .argb32, width: width, height: height))
	}
	
	public init(fromSize size: Vec2<Int>) throws {
		try self.init(width: size.x, height: size.y)
	}
	
	public init(fromPng data: Data) throws {
		self.init(from: try Surface.Image(png: data))
	}
	
	public init(fromPngFile url: URL) throws {
		let fileManager = FileManager.default
		guard fileManager.fileExists(atPath: url.path) else { throw DiskFileError.fileNotFound(url) }
		
		if let data = fileManager.contents(atPath: url.path) {
			try self.init(fromPng: data)
		} else {
			throw DiskFileError.noData("Image at \(url) contained no data")
		}
	}
	
	public init(fromPngFile filePath: String) throws {
		try self.init(fromPngFile: URL(fileURLWithPath: filePath))
	}
	
	public subscript(_ y: Int, _ x: Int) -> Color {
		get {
			var pixel: Color? = nil
			surface.withUnsafeMutableBytes { ptr in
				let i: Int = (y * surface.stride) + (x * bytesPerPixel!)
				let colorPtr = UnsafeMutableRawPointer(ptr + i)
				pixel = readColorFrom(pixel: colorPtr)
			}
			
			return pixel!
		}
		set(newColor) {
			surface.withUnsafeMutableBytes { ptr in
				let i: Int = (y * surface.stride) + (x * bytesPerPixel!)
				let colorPtr = UnsafeMutableRawPointer(ptr + i)
				store(color: newColor, inPixel: colorPtr)
			}
		}
	}
	
	/** Converts a color to the image's native representation. */
	private func store(color: Color, inPixel ptr: UnsafeMutableRawPointer) {
		switch surface.format {
			case .argb32?:
				ptr.storeBytes(of: color.argb, as: UInt32.self)
			default:
				print("Warning: Could not store color \(color) in an image with the format \(surface.format.map { "\($0)" } ?? "nil")")
		}
	}
	
	/** Convert's a color in the image's native representation to a color. */
	private func readColorFrom(pixel ptr: UnsafeMutableRawPointer) -> Color? {
		switch surface.format {
			case .argb32?:
				return Color(argb: ptr.load(as: UInt32.self))
			default:
				return nil
		}
	}
	
	public func pngEncoded() throws -> Data {
		return try surface.writePNG()
	}
}
