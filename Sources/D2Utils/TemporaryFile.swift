import Foundation
import Logging

fileprivate let log = Logger(label: "TemporaryFile")

/**
 * A custom temporary file. The file is deleted
 * when this instance is deinitialized.
 */
public class TemporaryFile {
	public let url: URL
	public var deleteAutomatically: Bool = false
	public var exists: Bool { return FileManager.default.fileExists(atPath: url.path) }
	
	public init(url: URL) {
		self.url = url
	}
	
	public func write(utf8 contents: String) throws {
		guard let data = contents.data(using: .utf8) else { throw EncodeError.couldNotEncode(contents) }
		try write(data: data)
	}
	
	public func write(data: Data) throws {
		let fileManager = FileManager.default
		
		if exists {
			try fileManager.removeItem(at: url)
		}
		
		fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
	}
	
	public func readData() -> Data? {
		return FileManager.default.contents(atPath: url.path)
	}
	
	public func readUTF8() -> String? {
		return readData().flatMap { String(data: $0, encoding: .utf8) }
	}
	
	public func delete() throws {
		try FileManager.default.removeItem(at: url)
	}
	
	deinit {
		do {
			if deleteAutomatically && exists {
				try delete()
			}
		} catch {
			log.error("Error while removing temporary file: \(error)")
		}
	}
}
