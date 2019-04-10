import SwiftDiscord
import D2Permissions
import Foundation

public class BFEncodeCommand: StringCommand {
	public let description = "Encodes strings to BF code"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let maxStringLength: Int
	
	public init(maxStringLength: Int = 30) {
		self.maxStringLength = maxStringLength
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard input.count <= maxStringLength || output.maxStringLength == nil else {
			output.append("Your string needs to be shorter than \(maxStringLength) characters!")
			return
		}
		
		let encoded = input.map { encode($0) ?? "" }.reduce("") { "\($0)>\($1)." }
		output.append("```\(encoded)```")
	}
	
	private func encode(_ character: Character) -> String? {
		guard let scalar = character.unicodeScalars.first?.value else { return nil }
		let floorLog = floor(log2(Double(scalar)))
		let remaining = scalar - UInt32(pow(2.0, floorLog))
		
		return "+" + (0..<Int(floorLog)).map { _ in "/" } + (0..<remaining).map { _ in "+" }
	}
}
