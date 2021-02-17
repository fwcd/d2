import Foundation

struct AkinatorServers: Codable {
    enum CodingKeys: String, CodingKey {
        case completion = "COMPLETION"
        case parameters = "PARAMETERS"
    }

    let completion: String
    let parameters: Parameters

    struct Parameters: Codable {
        enum CodingKeys: String, CodingKey {
            case instance = "INSTANCE"
        }

        let instance: [Instance]

        struct Instance: Codable {
            enum CodingKeys: String, CodingKey {
                case urlBaseWs = "URL_BASE_WS"
            }

            let urlBaseWs: URL
        }
    }
}
