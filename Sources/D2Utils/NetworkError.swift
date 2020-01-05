import Foundation

public enum NetworkError: Error {
	case couldNotCreateURL(URLComponents)
	case invalidAddress(String, Int32)
	case ioError(Error)
	case missingData
	case notUTF8(Data)
	case jsonDecodingError(String)
}
