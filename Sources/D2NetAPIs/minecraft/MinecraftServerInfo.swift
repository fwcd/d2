public struct MinecraftServerInfo: Codable {
    public let version: Version
    public let players: Players
    public let description: Chat
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
    
    public struct Chat: Codable {
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
}
