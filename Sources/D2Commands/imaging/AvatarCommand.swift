import SwiftDiscord
import D2Permissions
import D2Graphics
import Foundation

public class AvatarCommand: StringCommand {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Fetches the avatar of a user",
		longDescription: "Fetches the user's profile picture and outputs it in PNG form",
		helpText: "Syntax: [@user]",
		requiredPermissionLevel: .basic
	)
	public let outputValueType = .image
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let user = context.message.mentions.first else {
			output.append("Mention someone to begin!")
			return
		}
		guard let data = Data(base64Encoded: user.avatar) else {
			output.append("Could not decode Base64-encoded avatar data")
			return 
		}
		
		do {
			output.append(.image(try Image(fromPng: data)))
		} catch {
			output.append("Error: The conversion to an image failed")
		}
	}
}
