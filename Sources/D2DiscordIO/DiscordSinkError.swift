import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum DiscordSinkError: Error {
    case unsuccessful(String, response: HTTPURLResponse?)
    case httpError(String, status: Int)
    case noResponse(String)
}
