import D2MessageIO
import Discord

// TO Discord conversions

extension Message: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessage {
        let embed: Embed? = embeds.first
        return DiscordMessage(
            content: content,
            embed: embed?.usingDiscordAPI,
            files: files.usingDiscordAPI,
            tts: tts,
            components: components.usingDiscordAPI
        )
    }
}

extension Message.FileUpload: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordFileUpload {
        return DiscordFileUpload(data: data, filename: filename, mimeType: mimeType)
    }
}

extension Message.Component: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessageComponent {
        switch self {
            case .button(let button): return button.usingDiscordAPI
            case .selectMenu(let menu): return menu.usingDiscordAPI
            case .actionRow(let row): return row.usingDiscordAPI
        }
    }
}

extension Message.Component.Button: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessageComponent {
        .button(
            style: style?.usingDiscordAPI,
            label: label,
            customId: customId,
            disabled: disabled
        )
    }
}

extension Message.Component.SelectMenu: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessageComponent {
        .selectMenu(
            options: options.usingDiscordAPI,
            placeholder: placeholder,
            minValues: minValues,
            maxValues: maxValues,
            customId: customId,
            disabled: disabled
        )
    }
}

extension Message.Component.ActionRow: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessageComponent {
        .actionRow(
            components: components.usingDiscordAPI
        )
    }
}

extension Message.Component.Button.Style: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessageComponentButtonStyle {
        switch self {
            case .primary: return .primary
            case .secondary: return .secondary
            case .success: return .success
            case .danger: return .danger
            case .link: return .link
        }
    }
}

extension Message.Component.SelectMenu.Option: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessageComponentSelectOption {
        .init(
            label: label,
            value: value,
            description: description,
            emoji: emoji?.usingDiscordAPI,
            default: `default`
        )
    }
}

// FROM Discord conversions

extension DiscordMessage: MessageIOClientConvertible {
    public func usingMessageIO(with client: MessageClient) -> Message {
        let guild = guildId.flatMap { client.guild(for: $0.usingMessageIO) }
        let member = (author?.id).flatMap { guild?.members[$0.usingMessageIO] }
        return Message(
            content: content ?? "",
            embeds: embeds?.usingMessageIO ?? [],
            attachments: attachments?.usingMessageIO ?? [],
            activity: activity?.usingMessageIO,
            application: application?.usingMessageIO,
            author: author.usingMessageIO,
            channelId: channelId.usingMessageIO,
            editedTimestamp: editedTimestamp,
            id: id.usingMessageIO,
            mentionEveryone: mentionEveryone ?? false,
            mentionRoles: mentionRoles?.usingMessageIO ?? [],
            mentions: mentions?.usingMessageIO ?? [],
            nonce: nonce.usingMessageIO,
            pinned: pinned ?? false,
            reactions: reactions?.usingMessageIO ?? [],
            timestamp: timestamp,
            type: type.usingMessageIO,
            guild: guild,
            guildMember: member
        )
    }
}

extension DiscordAttachment: MessageIOConvertible {
    public var usingMessageIO: Message.Attachment {
        return Message.Attachment(
            id: id.usingMessageIO,
            filename: filename,
            size: size ?? 0,
            url: url,
            width: width,
            height: height
        )
    }
}

extension DiscordMessage.Activity: MessageIOConvertible {
    public var usingMessageIO: Message.Activity {
        return Message.Activity(
            type: type.usingMessageIO,
            partyId: partyId
        )
    }
}

extension DiscordMessage.Activity.ActivityType: MessageIOConvertible {
    public var usingMessageIO: Message.Activity.ActivityType {
        switch self {
            case .join: return .join
            case .spectate: return .spectate
            case .listen: return .listen
            case .joinRequest: return .joinRequest
            default: return .init(rawValue: rawValue)
        }
    }
}

extension DiscordApplication: MessageIOConvertible {
    public var usingMessageIO: Message.MessageApplication {
        return Message.MessageApplication(
            id: id.usingMessageIO,
            coverImage: coverImage,
            description: description,
            icon: icon,
            name: name
        )
    }
}

extension DiscordReaction: MessageIOConvertible {
    public var usingMessageIO: Message.Reaction {
        return Message.Reaction(
            count: count,
            me: me,
            emoji: emoji.usingMessageIO
        )
    }
}

extension DiscordMessageType: MessageIOConvertible {
    public var usingMessageIO: Message.MessageType {
        switch self {
            case .`default`: return .`default`
            case .recipientAdd: return .recipientAdd
            case .recipientRemove: return .recipientRemove
            case .call: return .call
            case .channelNameChange: return .channelNameChange
            case .channelIconChange: return .channelIconChange
            case .channelPinnedMessage: return .channelPinnedMessage
            case .guildMemberJoin: return .guildMemberJoin
            case .userPremiumGuildSubscription: return .userPremiumGuildSubscription
            case .userPremiumGuildSubscriptionTier1: return .userPremiumGuildSubscriptionTier1
            case .userPremiumGuildSubscriptionTier2: return .userPremiumGuildSubscriptionTier2
            case .userPremiumGuildSubscriptionTier3: return .userPremiumGuildSubscriptionTier3
            case .channelFollowAdd: return .channelFollowAdd
            case .guildDiscoveryDisqualified: return .guildDiscoveryDisqualified
            case .guildDiscoveryRequalified: return .guildDiscoveryRequalified
            case .reply: return .reply
            default: return .init(rawValue: rawValue)
        }
    }
}
