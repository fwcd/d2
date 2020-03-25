import Logging
import D2MessageIO
import D2Permissions
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.MDBCommand")

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
					output.append(errorText: "An error occurred while querying.")
					return
				}
				
				if let module = result.first {
					let embed = Embed(
						title: module.nameEnglish,
						description: module.summary,
						fields: [
							Embed.Field(name: "Person", value: module.person ?? "?", inline: true),
							Embed.Field(name: "ECTS", value: "\(module.ects ?? 0)", inline: true),
							Embed.Field(name: "Workload", value: module.workload ?? "?", inline: true),
							Embed.Field(name: "Language", value: module.teachingLanguage ?? "?", inline: true),
							Embed.Field(name: "Presence", value: module.presence ?? "?", inline: true),
							Embed.Field(name: "Cycle", value: module.cycle ?? "", inline: true),
							Embed.Field(name: "Duration", value: "\(module.duration ?? 0)", inline: true)
						]
					)
					
					output.append(embed)
				} else {
					output.append(errorText: "No such module found.")
				}
			}
		} catch {
			output.append(error)
		}
	}
}
