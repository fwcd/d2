import SwiftDiscord
import D2Graphics

/**
 * A value of a common format that
 * can be sent to an output.
 */
public enum RichValue {
	case none
	case text(String)
	case image(Image)
	case gif(AnimatedGif)
	case code(String)
	case codeWithLanguage(String, String) // Second parameter is the language
	case embed(DiscordEmbed?)
	case files([DiscordFileUpload])
	case compound([RichValue])
	
	var asText: String? {
		if case let .text(txt) = self {
			return txt
		} else {
			return nil
		}
	}
}
