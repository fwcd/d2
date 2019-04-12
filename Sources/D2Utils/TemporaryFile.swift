import Foundation

public class TemporaryFile {
	private let url: URL
	
	public init(suffix: String) {
		url = FileManager.default.temporaryDirectory
			.appendingPathComponent("\(UUID().uuidString)\(suffix)")
	}
	
	deinit {
		do {
			try FileManager.default.removeItem(at: url)
		} catch {
			print("Error while removing temporary file: \(error)")
		}
	}
}
