public struct MIOCommand {
    public let id: MIOCommandID
    public let applicationId: ApplicationID
    public let name: String
    public let description: String
    public let parameters: [Option]

    public init(
        id: MIOCommandID,
        applicationId: ApplicationID,
        name: String,
        description: String,
        parameters: [Option] = []
    ) {
        self.id = id
        self.applicationId = applicationId
        self.name = name
        self.description = description
        self.parameters = parameters
    }

    public struct Option {
        public let type: OptionType?
        public let name: String
        public let description: String
        public let isDefault: Bool?
        public let isRequired: Bool?
        public let choices: [Choice]?
        public let options: [Option]?

        public init(
            type: OptionType? = nil,
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

        public enum OptionType {
            case subCommand
            case subCommandGroup
            case string
            case integer
            case boolean
            case user
            case channel
            case role
        }
    }

    public struct InteractionData {
        public let id: MIOCommandID
        public let name: String
        public let options: [Option]

        public init(
            id: MIOCommandID,
            name: String,
            options: [Option] = []
        ) {
            self.id = id
            self.name = name
            self.options = options
        }

        public struct Option {
            public let name: String
            public let value: Any?
            public let options: [Option]

            public init(
                name: String,
                value: Any? = nil,
                options: [Option] = []
            ) {
                self.name = name
                self.value = value
                self.options = options
            }
        }
    }
}
