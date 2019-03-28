import Foundation

enum MDBError: Error {
	case missingData
	case urlError(URLComponents)
	case httpError(Error)
	case xmlError(String, Any)
}
