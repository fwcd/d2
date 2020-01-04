import SwiftDiscord
import Logging
import D2Permissions
import D2NetAPIs

fileprivate let log = Logger(label: "MDBCommand")

public class MDBCommand: StringCommand {
	public let info = CommandInfo(
		category: .cau,
		shortDescription: "Queries the MDB",
		longDescription: "Queries the Computer Science module database from the CAU",
		requiredPermissionLevel: .basic
	)

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
			log.warning("\(error)")
			output.append("An error occurred. Check the log for more information.")
		}
	}
}
