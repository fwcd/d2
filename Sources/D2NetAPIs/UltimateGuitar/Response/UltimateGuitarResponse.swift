public struct UltimateGuitarResponse<T>: Sendable, Codable where T: Sendable & Codable {
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
