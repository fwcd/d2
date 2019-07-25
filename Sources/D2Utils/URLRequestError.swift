import Foundation

public enum URLRequestError: Error {
	case couldNotCreateURL(URLComponents)
	case ioError(Error)
	case missingData
	case notUTF8(Data)
	case jsonDecodingError(Data)
}
