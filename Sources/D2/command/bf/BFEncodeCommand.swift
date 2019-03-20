import Sword
import Foundation

class BFEncodeCommand: Command {
	let description = "Encodes strings to BF code"
	private let maxStringLength: Int
	
	init(maxStringLength: Int = 30) {
		self.maxStringLength = maxStringLength
	}
	
	func invoke(withMessage message: Message, args: String) {
		guard args.count <= maxStringLength else {
			message.channel.send("Your string needs to be shorter than \(maxStringLength) characters!")
			return
		}
		
		let encoded = args.map { encode($0) ?? "" }.reduce("") { "\($0)>\($1)." }
		message.channel.send("```\(encoded)```")
	}
	
	private func encode(_ character: Character) -> String? {
		guard let scalar = character.unicodeScalars.first?.value else { return nil }
		let floorLog = floor(log2(Double(scalar)))
		let remaining = scalar - UInt32(pow(2.0, floorLog))
		
		return "+" + (0..<Int(floorLog)).map { _ in "/" } + (0..<remaining).map { _ in "+" }
	}
}
