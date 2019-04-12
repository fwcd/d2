import Foundation

/** A custom temporary directory. */
public class TemporaryDirectory {
	private let url: URL
	
	public init() {
		url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
	}
	
	public func childFile(name: String) -> TemporaryFile {
		return TemporaryFile(url: url.appendingPathComponent(name))
	}
	
	deinit {
		do {
			try FileManager.default.removeItem(at: url)
		} catch {
			print("Error while removing temporary directory: \(error)")
		}
	}
}
