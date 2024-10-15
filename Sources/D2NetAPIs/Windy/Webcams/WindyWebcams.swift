public struct WindyWebcams: Sendable, Codable {
    public let offset: Int
    public let limit: Int
    public let total: Int
    public let webcams: [Webcam]

    public struct Webcam: Sendable, Codable {
        public let id: String
        public let status: String
        public let title: String
        public let image: Image?

        public struct Image: Sendable, Codable {
            public let current: Previews
            public let sizes: Sizes?
            public let daylight: Previews?
            public let update: Int?

            public struct Previews: Sendable, Codable {
                public let icon: String
                public let thumbnail: String
                public let preview: String
                public let toenail: String
            }

            public struct Sizes: Sendable, Codable {
                public let icon: Size
                public let thumbnail: Size
                public let preview: Size
                public let toenail: Size

                public struct Size: Sendable, Codable {
                    public let width: Int
                    public let height: Int
                }
            }
        }
    }
}
