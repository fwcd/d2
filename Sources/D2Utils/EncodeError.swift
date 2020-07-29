import Foundation

public enum EncodeError: Error {
    case couldNotEncode(String)
    case couldNotDecode(Data)
}
