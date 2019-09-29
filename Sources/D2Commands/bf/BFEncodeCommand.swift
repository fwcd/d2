import SwiftDiscord
import D2Permissions
import Foundation

public class BFEncodeCommand: StringCommand {
	public let info = CommandInfo(
		category: .bf,
		shortDescription: "Encodes strings to BF code",
		longDescription: "Encodes a string such that the output is valid BF program, printing the given string",
		requiredPermissionLevel: .basic
	)
	private let maxStringLength: Int
	
	public init(maxStringLength: Int = 30) {
		self.maxStringLength = maxStringLength
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard input.count <= maxStringLength || output.messageLengthLimit == nil else {
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
