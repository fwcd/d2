import Foundation

public struct DallEMiniResponse: Codable {
    public let images: [String]
    public let version: String?

    public var decodedJpegImages: [Data] {
        images.compactMap { Data(base64Encoded: $0) }
    }
}
