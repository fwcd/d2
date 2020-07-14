import D2MessageIO
import D2Graphics

public class TileCommand: Command {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Replicates the image along the x-axis",
		helpText: "Syntax: [number of replicas]?",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .compound([.text, .image])
	public let outputValueType: RichValueType = .image
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		guard let text = input.asText, let replicas = text.isEmpty ? 2 : Int(text) else {
			output.append(errorText: "The number of (tiled) replicas should be an integer!")
			return
		}

		if let img = input.asImage {
			do {
				let width = img.width
				let height = img.height
				var tiled = try Image(width: width * replicas, height: height)
				
				for y in 0..<height {
					for x in 0..<width {
						for i in 0..<replicas {
							tiled[y, x + (i * width)] = img[y, x]
						}
					}
				}
				
				output.append(.image(tiled))
			} catch {
				output.append(error, errorText: "An error occurred while creating a new image")
			}
		} else {
			output.append(errorText: "Not an image!")
		}
	}
}
