import Foundation

public enum NetApiError: Error {
	case missingApiKey(String)
	case missingData
	case stringEncodingError(String)
	case urlStringError(String)
	case urlError(URLComponents)
	case httpError(Error)
	case xmlError(String, [String: String])
	case imageError(String)
	case jsonIOError(Error)
	case jsonParseError(String, String)
	case foundNoMatches(String)
	case noResults(String)
	case apiError(String)
}
