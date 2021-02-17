import Foundation

public struct AkinatorServers: Codable {
    public enum CodingKeys: String, CodingKey {
        case completion = "COMPLETION"
        case parameters = "PARAMETERS"
    }

    public let completion: String
    public let parameters: Parameters

    public struct Parameters: Codable {
        public enum CodingKeys: String, CodingKey {
            case instance = "INSTANCE"
        }

        public let instance: Instance

        public struct Instance: Codable {
            public enum CodingKeys: String, CodingKey {
                case urlBaseWs = "URL_BASE_WS"
            }

            public let urlBaseWs: URL
        }
    }
}
