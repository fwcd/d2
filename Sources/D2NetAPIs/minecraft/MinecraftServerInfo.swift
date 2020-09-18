public struct MinecraftServerInfo: Codable {
    public let version: Version
    public let players: Players
    public let description: Chat
    public let forgeData: ForgeData?
    public let modinfo: LegacyModInfo? // deprecated (pre-1.13)
    public let favicon: String?

    public struct Version: Codable {
        public enum CodingKeys: String, CodingKey {
            case name = "name"
            case protocolVersion = "protocol"
        }

        public let name: String
        public let protocolVersion: Int
    }

    public struct Players: Codable {
        public let max: Int
        public let online: Int
        public let sample: [Player]?

        public struct Player: Codable {
            public let name: String
            public let id: String
        }
    }

    public struct Chat: Codable, CustomStringConvertible {
        public let text: String
        public let bold: Bool?
        public let italic: Bool?
        public let underlined: Bool?
        public let strikethrough: Bool?
        public let obfuscated: Bool?
        public let color: String?
        public let insertion: String?
        public let clickEvent: ClickEvent?
        public let hoverEvent: HoverEvent?
        public let extra: [Chat]?

        public var description: String { return text + (extra?.map { "\($0)" }.joined() ?? "") }

        public struct ClickEvent: Codable {
            public enum CodingKeys: String, CodingKey {
                case openUrl = "open_url"
                case openFile = "open_file" // internal
                case runCommand = "run_command"
                case twitchUserInfo = "twitch_user_info" // deprecated
                case suggestCommand = "suggest_command"
                case changePage = "change_page"
            }

            public let openUrl: String?
            public let openFile: String?
            public let runCommand: String?
            public let twitchUserInfo: String?
            public let suggestCommand: String?
            public let changePage: Int?
        }

        public struct HoverEvent: Codable {
            public enum CodingKeys: String, CodingKey {
                case showText = "show_text"
                case showAchievement = "show_achievement" // deprecated
            }

            public let showText: String?
            public let showAchievement: String?
        }
    }

    public struct ForgeData: Codable {
        public let channels: [Channel]?
        public let mods: [Mod]?
        public let fmlNetworkVersion: Int?

        public struct Channel: Codable {
            public let res: String?
            public let version: String?
            public let required: Bool?
        }

        public struct Mod: Codable, CustomStringConvertible {
            public let modId: String
            public let modmarker: String
            public var description: String { return "\(modId) - \(modmarker)" }
        }
    }

    public struct LegacyModInfo: Codable {
        public let type: String?
        public let modList: [Mod]?

        public struct Mod: Codable, CustomStringConvertible {
            public let modid: String
            public let version: String
            public var description: String { return "\(modid) - \(version)" }
        }
    }
}
