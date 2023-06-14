import Foundation

struct FastApiResponse: Codable {
    let client: Client
    let targets: [Target]

    struct Location: Codable {
        let city: String?
        let country: String?
    }

    struct Client: Codable {
        let ip: String
        let asn: String?
        let isp: String?
        let location: Location?
    }

    struct Target: Codable {
        let name: String?
        let url: URL
        let location: Location?
    }
}
