import Cairo
import Foundation

public struct Image {
	let surface: Surface.Image
	
	public var width: Int { return surface.width }
	public var height: Int { return surface.height }
	public var size: Vec2<Int> { return Vec2(x: width, y: height) }
	
	init(from surface: Surface.Image) {
		self.surface = surface
	}
	
	public init(width: Int, height: Int) throws {
		self.init(from: try Surface.Image(format: .argb32, width: width, height: height))
	}
	
	public init(fromPng data: Data) throws {
		self.init(from: try Surface.Image(png: data))
	}
	
	public init(fromPngFile filePath: String) throws {
		let url = URL(fileURLWithPath: filePath)
		let fileManager = FileManager.default
		guard fileManager.fileExists(atPath: url.path) else { throw DiskFileError.fileNotFound(filePath) }
		
		if let data = fileManager.contents(atPath: url.path) {
			try self.init(fromPng: data)
		} else {
			throw DiskFileError.noData("Image at \(filePath) contained no data")
		}
	}
	
	public func pngEncoded() throws -> Data {
		return try surface.writePNG()
	}
}
