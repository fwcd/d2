import Foundation

public enum DiskFileError: Error {
	case fileNotFound(URL)
	case noData(String)
	case decodingError(String, Error)
}
