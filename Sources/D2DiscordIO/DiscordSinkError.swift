import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum DiscordSinkError: Error {
    case invalidResponse(HTTPURLResponse?)
}
