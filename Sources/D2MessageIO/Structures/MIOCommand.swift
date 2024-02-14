public struct MIOCommand {
    public let id: MIOCommandID
    public let applicationId: ApplicationID
    public let name: String
    public let description: String
    public let options: [Option]

    public init(
        id: MIOCommandID,
        applicationId: ApplicationID,
        name: String,
        description: String,
        options: [Option] = []
    ) {
        self.id = id
        self.applicationId = applicationId
        self.name = name
        self.description = description
        self.options = options
    }

    public struct Option {
        public let type: OptionType
        public let name: String
        public let description: String
        public let isDefault: Bool?
        public let isRequired: Bool?
        public let choices: [Choice]?
        public let options: [Option]?

        public init(
            type: OptionType,
            name: String,
            description: String,
            isDefault: Bool? = nil,
            isRequired: Bool? = nil,
            choices: [Choice]? = nil,
            options: [Option]? = nil
        ) {
            self.type = type
            self.name = name
            self.description = description
            self.isDefault = isDefault
            self.isRequired = isRequired
            self.choices = choices
            self.options = options
        }

        public struct Choice {
            public let name: String
            public let value: Value?

            public init(name: String, value: Value? = nil) {
                self.name = name
                self.value = value
            }

            public enum Value {
                case string(String)
                case int(Int)
            }
        }

        public struct OptionType: RawRepresentable, Hashable, Codable {
            public var rawValue: Int

            public static let unknown = OptionType(rawValue: -1)

            public static let subCommand = OptionType(rawValue: 1)
            public static let subCommandGroup = OptionType(rawValue: 2)
            public static let string = OptionType(rawValue: 3)
            public static let integer = OptionType(rawValue: 4)
            public static let boolean = OptionType(rawValue: 5)
            public static let user = OptionType(rawValue: 6)
            public static let channel = OptionType(rawValue: 7)
            public static let role = OptionType(rawValue: 8)
            public static let mentionable = OptionType(rawValue: 9)
            public static let number = OptionType(rawValue: 10)

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }
    }
}
