public struct MinecraftModSearchResult: Sendable, Codable {
    public let id: Int
    public let name: String?
    public let authors: [Author]?
    public let attachments: [Attachment]?
    public let websiteUrl: String?
    public let gameId: Int?
    public let summary: String?
    public let defaultFileId: Int?
    public let downloadCount: Int?
    public let latestFiles: [File]?
    public let categories: [Category]?
    public let status: Int?
    public let primaryCategoryId: Int?
    public let categorySection: CategorySection?
    public let slug: String?
    public let gameVersionLatestFiles: [GameVersionedFile]?
    public let isFeatured: Bool?
    public let popularityScore: Double?
    public let primaryLanguage: String?
    public let gameSlug: String?
    public let gameName: String?
    public let portalName: String?
    public let dateModified: String?
    public let dateCreated: String?
    public let isAvailable: Bool?
    public let isExperimental: Bool?

    public var defaultAttachment: Attachment? { attachments?.first { $0.isDefault ?? false } }

    public struct Author: Sendable, Codable {
        public let name: String?
        public let url: String?
        public let projectId: Int?
        public let id: Int?
        public let userId: Int?
        public let twitchId: Int?
    }

    public struct Attachment: Sendable, Codable {
        public let id: Int?
        public let projectId: Int?
        public let description: String?
        public let isDefault: Bool?
        public let thumbnailUrl: String?
        public let title: String?
        public let url: String?
        public let status: Int?
    }

    public struct File: Sendable, Codable {
        public let id: Int?
        public let displayName: String?
        public let fileName: String?
        public let fileDate: String?
        public let fileLength: Int?
        public let releaseType: Int?
        public let fileStatus: Int?
        public let downloadUrl: String?
        public let isAlternate: Bool?
        public let alternateFileId: Int?
        public let dependencies: [Dependency]?
        public let isAvailable: Bool?
        public let modules: [Module]?
        public let packageFingerprint: Int?
        public let gameVersion: [String]?
        public let sortableGameVersion: [GameVersion]?
        public let hasInstallScript: Bool?
        public let isCompatibleWithClient: Bool?
        public let categorySectionPackageType: Int?
        public let restrictProjectFileAccess: Int?
        public let projectStatus: Int?
        public let renderCacheId: Int?
        public let projectId: Int?
        public let packageFingerprintId: Int?
        public let gameVersionDateReleased: String?
        public let gameVersionMappingId: Int?
        public let gameVersionId: Int?
        public let gameId: Int?
        public let isServerPack: Bool?

        public struct Dependency: Sendable, Codable {
            public let id: Int?
            public let addonId: Int?
            public let type: Int?
            public let fileId: Int?
        }

        public struct Module: Sendable, Codable {
            public let foldername: String?
            public let fingerprint: Int?
            public let type: Int?
        }

        public struct GameVersion: Sendable, Codable {
            public let gameVersionPadded: String?
            public let gameVersion: String?
            public let gameVersionReleaseDate: String?
            public let gameVersionName: String?
        }
    }

    public struct Category: Sendable, Codable {
        public let categoryId: Int?
        public let name: String?
        public let url: String?
        public let avatarUrl: String?
        public let parentId: Int?
        public let rootId: Int?
        public let projectId: Int?
        public let avatarId: Int?
        public let gameId: Int?
    }

    public struct CategorySection: Sendable, Codable {
        public let id: Int?
        public let gameId: Int?
        public let name: String?
        public let packageType: Int?
        public let path: String?
        public let initialInclusionPattern: String?
        public let gameCategoryId: Int?
    }

    public struct GameVersionedFile: Sendable, Codable {
        public let gameVersion: String?
        public let projectFileId: Int?
        public let projectFileName: String?
        public let fileType: Int?
    }
}
