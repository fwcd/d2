import SwiftDiscord
import D2Permissions
import D2WebAPIs

public class MDBCommand: StringCommand {
	public let description = "Queries the Computer Science module database of the CAU"
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let query: MDBQuery
			
			if input.isEmpty {
				query = try MDBQuery()
			} else {
				query = try MDBQuery(moduleCode: input)
			}
			
			query.start { response in
				guard case let .success(result) = response else {
					output.append("An error occurred while querying.")
					return
				}
				
				if let module = result.first {
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
					
					output.append(embed)
				} else {
					output.append("No such module found.")
				}
			}
		} catch {
			print(error)
			output.append("An error occurred. Check the log for more information.")
		}
	}
}
