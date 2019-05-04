import Foundation

public enum HTTPRequestError: Error {
	case couldNotCreateURL(URLComponents)
	case ioError(Error)
	case missingData
	case notUTF8(Data)
	case jsonDecodingError(Data)
}
