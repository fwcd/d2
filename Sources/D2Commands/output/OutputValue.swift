import SwiftDiscord
import D2Graphics

/**
 * A value of a common format that
 * can be sent to an output.
 */
public enum OutputValue {
	case text(String)
	case image(Image)
	case gif(AnimatedGif)
	case code(String)
	case embed(DiscordEmbed)
	indirect case compound(OutputValue, OutputValue)
}
