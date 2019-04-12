import Foundation

public class TemporaryFile {
	private let url: URL
	
	public init(url: URL) {
		self.url = url
	}
	
	public func write(contents: String) throws {
		guard let data = contents.data(using: .utf8) else { throw EncodeError.couldNotEncode(contents) }
		let fileManager = FileManager.default
		
		if fileManager.fileExists(atPath: url.path) {
			try fileManager.removeItem(at: url)
		}
		
		fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
	}
	
	public func read() -> String? {
		return FileManager.default.contents(atPath: url.path).flatMap { String(data: $0, encoding: .utf8) }
	}
	
	deinit {
		do {
			try FileManager.default.removeItem(at: url)
		} catch {
			print("Error while removing temporary file: \(error)")
		}
	}
}
