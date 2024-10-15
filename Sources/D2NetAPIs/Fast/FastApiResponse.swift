import Foundation

struct FastApiResponse: Sendable, Codable {
    let client: Client
    let targets: [Target]

    struct Location: Sendable, Codable {
        let city: String?
        let country: String?
    }

    struct Client: Sendable, Codable {
        let ip: String
        let asn: String?
        let isp: String?
        let location: Location?
    }

    struct Target: Sendable, Codable {
        let name: String?
        let url: URL
        let location: Location?
    }
}
