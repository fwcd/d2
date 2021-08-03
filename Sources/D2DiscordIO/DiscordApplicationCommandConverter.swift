import Discord
import D2MessageIO

// TO Discord conversions

extension MIOCommand.Option: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordApplicationCommandOption {
        DiscordApplicationCommandOption(
            type: type.usingDiscordAPI,
            name: name,
            description: description,
            isDefault: isDefault,
            isRequired: isRequired,
            choices: choices?.usingDiscordAPI,
            options: options?.usingDiscordAPI
        )
    }
}

extension MIOCommand.Option.OptionType: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordApplicationCommandOptionType {
        switch self {
            case .subCommand: return .subCommand
            case .subCommandGroup: return .subCommandGroup
            case .string: return .string
            case .integer: return .integer
            case .boolean: return .boolean
            case .user: return .user
            case .channel: return .channel
            case .role: return .role
            default: return .init(rawValue: rawValue)
        }
    }
}

extension MIOCommand.Option.Choice: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordApplicationCommandOptionChoice {
        DiscordApplicationCommandOptionChoice(
            name: name,
            value: value?.usingDiscordAPI
        )
    }
}

extension MIOCommand.Option.Choice.Value: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordApplicationCommandOptionChoiceValue {
        switch self {
            case .string(let s): return .string(s)
            case .int(let i): return .int(i)
        }
    }
}

// FROM Discord conversions

extension DiscordApplicationCommand: MessageIOConvertible {
    public var usingMessageIO: MIOCommand {
        MIOCommand(
            id: id.usingMessageIO,
            applicationId: applicationId.usingMessageIO,
            name: name,
            description: description,
            parameters: parameters.usingMessageIO
        )
    }
}

extension DiscordApplicationCommandOption: MessageIOConvertible {
    public var usingMessageIO: MIOCommand.Option {
        MIOCommand.Option(
            type: type?.usingMessageIO ?? .unknown,
            name: name,
            description: description,
            isDefault: isDefault,
            isRequired: isRequired,
            choices: choices?.usingMessageIO,
            options: options?.usingMessageIO
        )
    }
}

extension DiscordApplicationCommandOptionType: MessageIOConvertible {
    public var usingMessageIO: MIOCommand.Option.OptionType {
        switch self {
            case .subCommand: return .subCommand
            case .subCommandGroup: return .subCommandGroup
            case .string: return .string
            case .integer: return .integer
            case .boolean: return .boolean
            case .user: return .user
            case .channel: return .channel
            case .role: return .role
            default: return .init(rawValue: rawValue)
        }
    }
}

extension DiscordApplicationCommandOptionChoice: MessageIOConvertible {
    public var usingMessageIO: MIOCommand.Option.Choice {
        MIOCommand.Option.Choice(
            name: name,
            value: value?.usingMessageIO
        )
    }
}

extension DiscordApplicationCommandOptionChoiceValue: MessageIOConvertible {
    public var usingMessageIO: MIOCommand.Option.Choice.Value {
        switch self {
            case .string(let s): return .string(s)
            case .int(let i): return .int(i)
        }
    }
}

extension DiscordApplicationCommandInteractionData: MessageIOConvertible {
    public var usingMessageIO: MIOCommand.InteractionData {
        MIOCommand.InteractionData(
            id: id?.usingMessageIO,
            name: name ?? "",
            options: options?.usingMessageIO ?? []
        )
    }
}

extension DiscordApplicationCommandInteractionDataOption: MessageIOConvertible {
    public var usingMessageIO: MIOCommand.InteractionData.Option {
        MIOCommand.InteractionData.Option(
            name: name,
            options: options?.usingMessageIO ?? []
        )
    }
}
