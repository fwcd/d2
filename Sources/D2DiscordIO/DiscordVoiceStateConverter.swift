import SwiftDiscord
import D2MessageIO

// FROM Discord conversions

extension DiscordVoiceState: MessageIOConvertible {
    public var usingMessageIO: VoiceState {
        return VoiceState(
            channelId: channelId.usingMessageIO,
            guildId: guildId.usingMessageIO,
            userId: userId.usingMessageIO,
            deaf: deaf,
            mute: mute,
            selfDeaf: selfDeaf,
            selfMute: selfMute,
            suppress: suppress
        )
    }
}
