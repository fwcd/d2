import Foundation
import CairoGraphics
import Utils

nonisolated(unsafe) private let pngDataUrlPattern = #/data:image\/png;base64,(?<base64>.*)/#

public struct MinecraftServerInfo: Codable {
    public let version: Version
    public let players: Players
    public let description: Chat
    public let forgeData: ForgeData?
    public let modinfo: LegacyModInfo? // deprecated (pre-1.13)
    public let favicon: String?

    public var faviconImage: CairoImage? {
        favicon
            .flatMap { try? pngDataUrlPattern.firstMatch(in: $0) }
            .flatMap { Data(base64Encoded: String($0.base64)) }
            .flatMap { try? CairoImage(pngData: $0) }
    }

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
        public var bold: Bool? = nil
        public var italic: Bool? = nil
        public var underlined: Bool? = nil
        public var strikethrough: Bool? = nil
        public var obfuscated: Bool? = nil
        public var color: String? = nil
        public var insertion: String? = nil
        public var clickEvent: ClickEvent? = nil
        public var hoverEvent: HoverEvent? = nil
        public var extra: [Chat]? = nil

        public var description: String { return text + (extra?.map { "\($0)" }.joined() ?? "") }

        public init(from decoder: Decoder) throws {
            if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                text = try container.decode(String.self, forKey: .text)
                bold = try? container.decode(Bool.self, forKey: .bold)
                italic = try? container.decode(Bool.self, forKey: .italic)
                underlined = try? container.decode(Bool.self, forKey: .underlined)
                strikethrough = try? container.decode(Bool.self, forKey: .strikethrough)
                obfuscated = try? container.decode(Bool.self, forKey: .obfuscated)
                color = try? container.decode(String.self, forKey: .color)
                insertion = try? container.decode(String.self, forKey: .insertion)
                clickEvent = try? container.decode(ClickEvent.self, forKey: .clickEvent)
                hoverEvent = try? container.decode(HoverEvent.self, forKey: .hoverEvent)
                extra = try? container.decode([Chat].self, forKey: .extra)
            } else {
                let container = try decoder.singleValueContainer()
                text = try container.decode(String.self)
            }
        }

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
