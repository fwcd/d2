import SwiftDiscord

class MDBCommand: Command {
	let description = "Queries the Computer Science module database of the CAU"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withMessage message: DiscordMessage, args: String) {
		do {
			let query: MDBQuery
			
			if args.isEmpty {
				query = try MDBQuery()
			} else {
				query = try MDBQuery(moduleCode: args)
			}
			
			query.start { response in
				guard case let .ok(output) = response else {
					message.channel?.send("An error occurred while querying.")
					return
				}
				
				if let module = output.first {
					var embed = DiscordEmbed()
					
					embed.title = module.nameEnglish
					embed.description = module.summary
					embed.fields = [
						DiscordEmbed.Field(name: "Person", value: module.person ?? "?", inline: true),
						DiscordEmbed.Field(name: "ECTS", value: "\(module.ects ?? 0)", inline: true),
						DiscordEmbed.Field(name: "Workload", value: module.workload ?? "?", inline: true),
						DiscordEmbed.Field(name: "Language", value: module.teachingLanguage ?? "?", inline: true),
						DiscordEmbed.Field(name: "Presence", value: module.presence ?? "?", inline: true),
						DiscordEmbed.Field(name: "Cycle", value: module.cycle ?? "", inline: true),
						DiscordEmbed.Field(name: "Duration", value: "\(module.duration ?? 0)", inline: true)
					]
					
					message.channel?.send(embed: embed)
				} else {
					message.channel?.send("No such module found.")
				}
			}
		} catch {
			print(error)
			message.channel?.send("An error occurred. Check the log for more information.")
		}
	}
}
