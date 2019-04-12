import Foundation

/**
 * A custom temporary directory. The directory is deleted
 * when this instance is deinitialized.
 */
public class TemporaryDirectory {
	public let url: URL
	public var deleteAutomatically: Bool = true
	public var exists: Bool { return FileManager.default.fileExists(atPath: url.path) }
	
	public init() {
		let fileManager = FileManager.default
		let temporaryDirectory: URL
		
		if #available(macOS 10.12, *) {
			temporaryDirectory = fileManager.temporaryDirectory
		} else {
			temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
		}
		
		url = temporaryDirectory.appendingPathComponent(UUID().uuidString)
	}
	
	public func create(withIntermediateDirectories: Bool = true) throws {
		try FileManager.default.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories)
	}
	
	public func childFile(named name: String) -> TemporaryFile {
		return TemporaryFile(url: url.appendingPathComponent(name))
	}
	
	deinit {
		do {
			if deleteAutomatically && exists {
				try FileManager.default.removeItem(at: url)
			}
		} catch {
			print("Error while removing temporary directory: \(error)")
		}
	}
}
