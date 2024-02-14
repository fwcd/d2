public struct RedditLink: Codable {
    public enum CodingKeys: String, CodingKey {
        case subreddit
        case id
        case title
        case selftext
        case url
        case permalink
        case author
        case authorFlairType = "author_flair_type"
        case authorFullname = "author_fullname"
        case authorPatreonFlair = "author_patreon_flair"
        case authorPremium = "author_premium"
        case saved
        case subredditNamePrefixed = "subreddit_name_prefixed"
        case hidden
        case pwls
        case ups
        case downs
        case thumbnail
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
        case hideScore = "hide_score"
        case name
        case quarantine
        case subredditType = "subreddit_type"
        case gilded
        case allAwardings = "all_awardings"
        case totalAwardsReceived = "total_awards_received"
        case isOriginalContent = "is_original_content"
        case isRedditMediaDomain = "is_reddit_media_domain"
        case isMeta
        case canModPost = "can_mod_post"
        case score
        case edited
        case postHint = "post_hint"
        case isSelf = "is_self"
        case created
        case linkFlairTextColor = "link_flair_text_color"
        case linkFlairType = "link_flair_type"
        case linkFlairBackgroundColor = "link_flair_background_color"
        case linkFlairRichText = "link_flair_richtext"
        case wls
        case domain
        case allowLiveComments = "allow_live_comments"
        case archived
        case noFollow = "no_follow"
        case isCrosspostable = "is_crosspostable"
        case pinned
        case over18 = "over_18"
        case preview
        case mediaOnly = "media_only"
        case canGild = "can_gild"
        case spoiler
        case locked
        case visited
        case subredditId = "subreddit_id"
        case isRobotIndexable = "is_robot_indexable"
        case numComments = "num_comments"
        case sendReplies = "send_replies"
        case whitelistStatus = "whitelist_status"
        case parentWhitelistStatus = "parent_whitelist_status"
        case contestMode = "contest_mode"
        case stickied
        case subredditSubscribers = "subreddit_subscribers"
        case createdUtc = "created_utc"
        case numCrossposts = "num_crossposts"
        case isVideo = "is_video"
    }

    public let subreddit: String?
    public let id: String?
    public let title: String?
    public let selftext: String?
    public let url: String?
    public let permalink: String?
    public let author: String?
    public let authorFlairType: String?
    public let authorFullname: String?
    public let authorPatreonFlair: Bool?
    public let authorPremium: Bool?
    public let saved: Bool?
    public let subredditNamePrefixed: String?
    public let hidden: Bool?
    public let pwls: Int?
    public let ups: Int?
    public let downs: Int?
    public let thumbnail: String?
    public let thumbnailWidth: Int?
    public let thumbnailHeight: Int?
    public let hideScore: Bool?
    public let name: String?
    public let quarantine: Bool?
    public let subredditType: String?
    public let gilded: Int?
    public let allAwardings: [Awarding]?
    public let totalAwardsReceived: Int?
    public let isOriginalContent: Bool?
    public let isRedditMediaDomain: Bool?
    public let isMeta: Bool?
    public let canModPost: Bool?
    public let score: Int?
    public let edited: Bool?
    public let postHint: String?
    public let isSelf: Bool?
    public let created: Int?
    public let linkFlairType: String?
    public let linkFlairTextColor: String?
    public let linkFlairBackgroundColor: String?
    public let linkFlairRichText: [RichTextFragment]?
    public let wls: Int?
    public let domain: String?
    public let allowLiveComments: Bool?
    public let archived: Bool?
    public let noFollow: Bool?
    public let isCrosspostable: Bool?
    public let pinned: Bool?
    public let over18: Bool?
    public let preview: Preview?
    public let mediaOnly: Bool?
    public let canGild: Bool?
    public let spoiler: Bool?
    public let locked: Bool?
    public let visited: Bool?
    public let subredditId: String?
    public let isRobotIndexable: Bool?
    public let numComments: Int?
    public let sendReplies: Bool?
    public let whitelistStatus: String?
    public let parentWhitelistStatus: String?
    public let contestMode: Bool?
    public let stickied: Bool?
    public let subredditSubscribers: Int?
    public let createdUtc: Int?
    public let numCrossposts: Int?
    public let isVideo: Bool?

    public struct UrlWithSize: Codable {
        public let url: String?
        public let width: Int?
        public let height: Int?
    }

    public struct Preview: Codable {
        public let images: [Resource]?
        public let enabled: Bool?

        public var firstGif: Resource? { images?.compactMap { $0.variants?.gif }.first }

        public class Resource: Codable {
            public let source: UrlWithSize?
            public let resolutions: [UrlWithSize]?
            public let variants: Variants?

            public struct Variants: Codable {
                public let gif: Resource?
                public let mp4: Resource?
            }
        }
    }

    public struct RichTextFragment: Codable {
        public let e: String?
        public let t: String?
    }

    public struct Awarding: Codable {
        public enum CodingKeys: String, CodingKey {
            case id
            case name
            case count
            case isEnabled = "is_enabled"
            case description
            case coinReward = "coin_reward"
            case iconUrl = "icon_url"
            case daysOfPremium = "days_of_premium"
            case coinPrice = "coin_price"
            case isNew = "is_new"
            case awardSubType = "award_sub_type"
            case resizedIcons = "resized_icons"
            case iconWidth = "icon_width"
            case iconHeight = "icon_height"
            case awardType = "award_type"
        }

        public let id: String?
        public let name: String?
        public let count: Int?
        public let isEnabled: Bool?
        public let description: String?
        public let coinReward: Int?
        public let iconUrl: String?
        public let daysOfPremium: Int?
        public let coinPrice: Int?
        public let isNew: Bool?
        public let awardSubType: String?
        public let resizedIcons: [UrlWithSize]?
        public let iconWidth: Int?
        public let iconHeight: Int?
        public let awardType: String?
    }
}
