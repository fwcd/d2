import D2MessageIO
import Discord

// TO Discord conversions

extension Message: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessage {
        return DiscordMessage(
            content: content,
            embeds: embeds.usingDiscordAPI,
            files: files.usingDiscordAPI,
            tts: tts,
            components: components.usingDiscordAPI
        )
    }
}

extension Message.Edit: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordMessage.Edit {
        return DiscordMessage.Edit(
            content: content,
            embeds: embeds?.usingDiscordAPI,
            components: components?.usingDiscordAPI
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
            case .button(let button): button.usingDiscordAPI
            case .selectMenu(let menu): menu.usingDiscordAPI
            case .actionRow(let row): row.usingDiscordAPI
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
            case .primary: .primary
            case .secondary: .secondary
            case .success: .success
            case .danger: .danger
            case .link: .link
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
    public func usingMessageIO(with sink: any Sink) -> Message {
        let guild = guildId.flatMap { sink.guild(for: $0.usingMessageIO) }
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
            case .join: .join
            case .spectate: .spectate
            case .listen: .listen
            case .joinRequest: .joinRequest
            default: .init(rawValue: rawValue)
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
            case .`default`: .`default`
            case .recipientAdd: .recipientAdd
            case .recipientRemove: .recipientRemove
            case .call: .call
            case .channelNameChange: .channelNameChange
            case .channelIconChange: .channelIconChange
            case .channelPinnedMessage: .channelPinnedMessage
            case .guildMemberJoin: .guildMemberJoin
            case .userPremiumGuildSubscription: .userPremiumGuildSubscription
            case .userPremiumGuildSubscriptionTier1: .userPremiumGuildSubscriptionTier1
            case .userPremiumGuildSubscriptionTier2: .userPremiumGuildSubscriptionTier2
            case .userPremiumGuildSubscriptionTier3: .userPremiumGuildSubscriptionTier3
            case .channelFollowAdd: .channelFollowAdd
            case .guildDiscoveryDisqualified: .guildDiscoveryDisqualified
            case .guildDiscoveryRequalified: .guildDiscoveryRequalified
            case .reply: .reply
            default: .init(rawValue: rawValue)
        }
    }
}
