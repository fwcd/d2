import Foundation

public struct DiskStorage {
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()
	
	public init() {}
	
	public func write<T: Encodable>(_ value: T, asJsonToFile filePath: String) throws {
		let url = URL(fileURLWithPath: filePath)
		let fileManager = FileManager.default
		let data = try encoder.encode(value)
		
		if fileManager.fileExists(atPath: url.path) {
			try fileManager.removeItem(at: url)
		}
		
		fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
	}

	public func readJson<T: Decodable>(as type: T.Type, fromFile filePath: String) throws -> T {
		let url = URL(fileURLWithPath: filePath)
		let fileManager = FileManager.default
		guard fileManager.fileExists(atPath: url.path) else { throw SerializationError.fileNotFound(filePath) }
		
		if let data = fileManager.contents(atPath: url.path) {
			return try decoder.decode(type, from: data)
		} else {
			throw SerializationError.noData("Could not read any data from '\(filePath)'")
		}
	}
}
