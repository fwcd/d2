public struct UltimateGuitarResponse<T> {
    public let store: Store

    public struct Store: Sendable, Codable {
        public let page: Page

        public struct Page: Sendable, Codable {
            public let template: Template
            public let data: T

            public struct Template: Sendable, Codable {
                public let module: String
                public let controller: String?
                public let action: String?
                public let reactAction: String?
            }
        }
    }
}

extension UltimateGuitarResponse: Sendable where T: Sendable {}
extension UltimateGuitarResponse: Encodable where T: Encodable {}
extension UltimateGuitarResponse: Decodable where T: Decodable {}
