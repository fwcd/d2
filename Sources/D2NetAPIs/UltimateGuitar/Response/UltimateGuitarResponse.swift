public struct UltimateGuitarResponse<T>: Codable where T: Codable {
    public let store: Store

    public struct Store: Codable {
        public let page: Page

        public struct Page: Codable {
            public let template: Template
            public let data: T

            public struct Template: Codable {
                public let module: String
                public let controller: String?
                public let action: String?
                public let reactAction: String?
            }
        }
    }
}
