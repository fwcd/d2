import D2MessageIO
import D2Permissions
import D2Graphics
import D2Utils
import Foundation

public class AvatarCommand: StringCommand {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Fetches the avatar of a user",
		longDescription: "Fetches the user's profile picture and outputs it in PNG form",
		helpText: "Syntax: [@user]",
		requiredPermissionLevel: .basic
	)
	public let outputValueType: RichValueType = .image
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let user = context.message.mentions.first else {
			output.append("Mention someone to begin!")
			return
		}
		
		do {
			try HTTPRequest(
				scheme: "https",
				host: "cdn.discordapp.com",
				path: "/avatars/\(user.id)/\(user.avatar).png",
				query: ["size": "256"]
			).runAsync {
				if case let .success(data) = $0 {
					do {
						if data.isEmpty {
							output.append(.text("No avatar available"))
						} else {
							output.append(.image(try Image(fromPng: data)))
						}
					} catch {
						output.append("Error: The image conversion failed: \(error)")
					}
				} else if case let .failure(error) = $0 {
					output.append("Error: The avatar could not be fetched \(error)")
				}
			}
		} catch {
			output.append("Error: The avatar request failed")
		}
	}
}
