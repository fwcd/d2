import Cairo
import Foundation

public struct Image {
	private let surface: Surface
	
	public var width: Int { return surface.width }
	public var height: Int { return surface.height }
	public var size: Vec2<Int> { return Vec2(x: width, y: height) }
	
	public init(from surface: Surface) {
		self.surface = surface
	}
	
	public init(fromPng data: Data) {
		self.init(from: Surface.Image(png: data))
	}
	
	public init?(fromPngFile filePath: String) {
		let url = URL(fileURLWithPath: filePath)
		let fileManager = FileManager.default
		guard fileManager.fileExists(atPath: url.path) else { return nil }
		
		if let data = fileManager.contents(atPath: url.path) {
			self = Image(fromPng: data)
		} else {
			return nil
		}
	}
	
	public func pngEncoded() throws -> Data {
		return try surface.writePNG()
	}
}
